require 'spec_helper'

Fhir::Meta::Resource.load(FHIR_FILE)
file_name = File.join(File.dirname(__FILE__), '..', '..', 'fhir-base.xsd')
Fhir::Meta::Datatype.load(file_name)

describe "Fhir::Meta::ModelsBuilder" do
  let(:m) { Fhir::Meta::ElementsBuilder }

  it "monadic" do
    res = m.monadic([1,2,3])
    res.should be_a(Fhir::Meta::SimpleMonad)
  end

  it "element" do
    m.element(%w[a b c], opt1: 'val1').should be_a(Fhir::Meta::Element)
  end

  let(:elements) {
    m.monadic([
      m.element(%w[a]),
      m.element(%w[a b]),
      m.element(%w[a b c]),
    ])
  }

  it "find by path" do
    elements
    .find_by_path(%w[a b])
    .all
    .should_not be_nil
  end

  it "filter descendants" do
    res = elements
    .filter_descendants(%w[a b])
    .all

    res.size.should == 1
    res.first.path.to_a.should == %w[a b c]
  end

  it 'should filter children' do
    m.monadic([
      m.element(['Entity']),
      m.element(['Entity','prop']),
      m.element(['Entity','prop2']),
      m.element(['Entity','ass1'], max: '*'),
      m.element(['Entity','ass1','prop3']),
      m.element(['Entity','ass2'], max: '1'),
      m.element(['Entity','ass1','prop4'])
    ])
    .filter_children(['Entity']).all
    .map(&:path)
    .map(&:last)
    .sort.should == %w[prop prop2 ass1 ass2].sort
  end

  it "monadic" do
    el = m.monadic
    .resource_elements
    .find_by_path(['MedicationStatement'])
    .all
    .first

    el.should_not be_nil
  end

  it "filter_technical_elements" do

    m.monadic([m.element(['one','text'])])
    .filter_technical_elements
    .all
    .should == []

    m.monadic([m.element(['one','text'])])
    .filter_technical_elements
    .all
    .should == []

    m.monadic([m.element(['one','extension'])])
    .filter_technical_elements
    .all
    .should == []

    m.monadic([m.element(['one','contained'])])
    .filter_technical_elements
    .all
    .should == []

    m.monadic([m.element(['one','two'])])
    .filter_technical_elements
    .all
    .should_not be_empty
  end

  it "modlize" do
    res = m.monadic([
      m.element(['Entity']),
      m.element(['Entity','prop']),
      m.element(['Entity','prop2']),
      m.element(['Entity','ass'], max: '*'),
      m.element(['Entity','ass','prop3'])
    ]).modelize.all

    res.size.should == 2
    entity = res.sort_by(&:path).first
    entity.path.should == ['Entity']
    entity.elements.all.size.should == 3
  end
  it 'should apply rulez' do
    m.monadic([
      m.element(['Entity']),
      m.element(['Entity','prop'], max: '1'),
      m.element(['Entity','prop2'])
    ]).apply_rules(['Entity','prop'] => {max: '*'})
    .find_by_path(['Entity','prop'])
    .all.first.max.should == '*'
  end


  it 'filter_alone_descendants' do
    res = m.monadic([
      m.element(['Entity']),
      m.element(['Entity','prop']),
      m.element(['Entity','prop2']),
      m.element(['Entity','ass2'], max: '1'),
      m.element(['Entity','ass1'], max: '*'),
      m.element(['Entity','ass1','prop3']), #should be removed
      m.element(['Entity','ass1','prop4']), #should be removed
    ])
    .filter_alone_descendants(['Entity'])
    .all

    res.map(&:path).map(&:last).should_not include('prop3')
    res.map(&:path).map(&:last).should_not include('prop4')

    res.size.should == 4
  end

  it "template" do
    m.monadic([
      m.element(%w[a b])
    ]).template do
      <<-ERB
item: <%= el.path -%>
      ERB
    end
    .all
    .first.code.should == "item: a.b"
  end

  it "file" do
    tmp_folder = File.join(File.dirname(__FILE__), 'tmp')
    FileUtils.rm_rf(tmp_folder)

    m.monadic([
      m.element(%w[one], code: 'odin'),
      m.element(%w[two], code: 'dva')
    ])
    .file(tmp_folder) do |el|
      "#{el.path}.txt"
    end

    File.exists?("#{tmp_folder}/one.txt").should be_true
    File.open("#{tmp_folder}/one.txt").readlines.first.should == 'odin'
  end

  it 'should tableize' do
    res = m.monadic([
      m.element(['Entity']),
      m.element(['Entity','prop']),
      m.element(['Entity','prop2']),

      m.element(['Entity','ass1'], max: '*'),
      m.element(['Entity','ass1','prop3']),

      m.element(['Entity','ass2'], max: '1'),
      m.element(['Entity','ass2','prop4'])
    ]).tableize.all

    res.size.should == 3
  end
end
