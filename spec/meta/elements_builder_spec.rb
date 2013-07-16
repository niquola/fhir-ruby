require 'spec_helper'
require "erb"

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
    ]).modelize
    .print do |el|
      "#{el.first.join('.')}: #{el.last.map(&:attributes).inspect}"
    end.all

      res[['Entity']].should_not be_nil
      res[['Entity','ass']].should_not be_nil
      res.length.should == 2
  end

  it "visualize" do
    m.monadic
    .resource_elements
    .filter_technical_elements
    .expand_with_datatypes
    .sort(&:path)
    .print
  end

  it "template" do
    m.monadic
    .resource_elements
    .expand_with_datatypes
    .filter_technical_elements
    .filter_descendants(['MedicationStatement'])
    .modelize
    .template do
      <<-ERB
class <%= el.first.map(&:camelize).join %>
  <% monadic(el.last).filter_simple_types.each do |attr| -%>
   attr_accessor <%= attr.path.last -%> # <%= attr.type -%> <%= attr.max %>
  <% end -%>

  <% el.last.reject{|e| e.attributes[:simple]}.each do |attr| -%>
   association <%= attr.path.last %> # <%= attr.type %> <%= attr.max %>
  <% end -%>
end
      ERB
    end.print
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
end
