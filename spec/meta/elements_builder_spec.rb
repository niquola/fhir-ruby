require 'spec_helper'

Fhir::Meta::Resource.load(FHIR_FILE)
file_name = File.join(File.dirname(__FILE__), '..', '..', 'fhir-base.xsd')
Fhir::Meta::Datatype.load(file_name)

describe "Fhir::Meta::ModelsBuilder" do
  let(:m) { Fhir::Meta::ElementsBuilder }

  it "monadic" do
    el = m.monadic
    .resource_elements
    .find_by_path(['MedicationStatement'])
    .all
    .first

    el.should_not be_nil
  end

  it "filter_technical_elements" do

    m.monadic([m.element(path:['one','text'])])
    .filter_technical_elements
    .all
    .should == []

    m.monadic([m.element(path:['one','text'])])
    .filter_technical_elements
    .all
    .should == []

    m.monadic([m.element(path:['one','extension'])])
    .filter_technical_elements
    .all
    .should == []

    m.monadic([m.element(path:['one','contained'])])
    .filter_technical_elements
    .all
    .should == []

    m.monadic([m.element(path:['one','two'])])
    .filter_technical_elements
    .all
    .should_not be_empty
  end

  it "modlize" do
    res = m.monadic([
      m.element(path:['Entity']),
      m.element(path:['Entity','prop']),
      m.element(path:['Entity','prop2']),
      m.element(path:['Entity','ass'], max: '*'),
      m.element(path:['Entity','ass','prop3'])
    ]).modelize.all

    res.size.should == 2
    entity = res.sort_by(&:path).first
    entity.path.should == ['Entity']
    entity.elements.all.size.should == 3
  end
  it 'should apply rulez' do
    m.monadic([
      m.element(path:['Entity']),
      m.element(path:['Entity','prop'], max: '1'),
      m.element(path:['Entity','prop2'])
    ]).apply_rules(['Entity','prop'] => {max: '*'})
    .find_by_path(['Entity','prop'])
    .all.first.max.should == '*'
  end

  it 'should filter children' do
    res = m.monadic([
      m.element(path:['Entity']),
      m.element(path:['Entity','prop']),
      m.element(path:['Entity','prop2']),
      m.element(path:['Entity','ass1'], max: '*'),
      m.element(path:['Entity','ass1','prop3']),
      m.element(path:['Entity','ass2'], max: '1'),
      m.element(path:['Entity','ass1','prop4'])
    ])
    .filter_children(['Entity']).all
    .map(&:path).map(&:last).should =~ %w[prop prop2 ass1 ass2]
  end

  it 'filter_alone_descendants' do

    res = m.monadic([
      m.element(path:['Entity']),
      m.element(path:['Entity','prop']),
      m.element(path:['Entity','prop2']),
      m.element(path:['Entity','ass1'], max: '*'),
      m.element(path:['Entity','ass1','prop3']), #should be removed
      m.element(path:['Entity','ass1','prop4']), #should be removed
      m.element(path:['Entity','ass2'], max: '1'),
    ])
    .filter_alone_descendants(['Entity'])
    .all

    res.map(&:path).map(&:last).should_not include('prop3')
    res.map(&:path).map(&:last).should_not include('prop4')

    res.size.should == 7
  end

  it "template" do
    m.monadic([1,2,3])
    .template do
      <<-ERB
        item: <%= el %>
      ERB
    end.print
  end

  it "file" do
    tmp_folder = File.join(File.dirname(__FILE__), 'tmp')
    FileUtils.rm_rf(tmp_folder)

    m.monadic([%w[one odin], %w[two dva]])
    .file(tmp_folder) do |el|
      "#{el}.txt"
    end

    File.exists?("#{tmp_folder}/one.txt").should be_true
    File.open("#{tmp_folder}/one.txt").readlines.first.should == 'odin'
  end

  it 'should tableize' do
    res = m.monadic([
      m.element(path:['Entity']),
      m.element(path:['Entity','prop']),
      m.element(path:['Entity','prop2']),

      m.element(path:['Entity','ass1'], max: '*'),
      m.element(path:['Entity','ass1','prop3']),

      m.element(path:['Entity','ass2'], max: '1'),
      m.element(path:['Entity','ass2','prop4'])
    ]).tableize.all

    res.all.size.should == 2
  end
end
