require 'spec_helper'
require "erb"

Fhir::Meta::Resource.load(FHIR_FILE)
file_name = File.join(File.dirname(__FILE__), '..', '..', 'fhir-base.xsd')
Fhir::Meta::Datatype.load(file_name)

describe "Fhir::Meta::ModelsBuilder" do
  before(:all) do
    builder = Fhir::Meta::ModelsBuilder.new
    builder.build
    @models = builder.models
  end

  def models
    @models
  end

  example do
    medication_statment = models.find do |m|
      m.full_name == "MedicationStatement"
    end
    medication_statment.should_not be_nil
    medication_statment_dosage = models.find do |m|
      m.full_name == "MedicationStatementDosage"
    end
    medication_statment_dosage.should_not be_nil

    attr = medication_statment.attributes.find do |a|
      a.name == 'was_not_given'
    end
    attr.should_not be_nil
    attr.type.should == 'boolean'
  end

  example do
    identifier = models.find do |m|
      m.full_name == "MedicationStatementIdentifier"
    end
    identifier.attributes.size.should == 4

    coding = models.find do |m|
      m.full_name == "MedicationStatementDosageSiteCoding"
    end
    coding.should_not be_nil
  end

  it "should fill refs" do
    statement = models.find do |m|
      m.full_name == "MedicationStatement"
    end

    medication = statement.resource_refs.find{|r| r.name == 'medication' }
    medication.should_not be_nil
  end

  it "should fill refs" do
    medication = models.find do |m|
      m.full_name == "MedicationStatementMedication"
    end
    medication.attributes.should_not be_empty

    #p medication

    medication_coding = models.find do |m|
      m.full_name == "MedicationStatementMedicationCodeCoding"
    end
    medication_coding.should_not be_nil
  end

  example do
    models.sort_by(&:full_name).each do |m|
      puts '-'*20
      puts m.full_name
      puts "parent: #{m.parent && m.parent.full_name}"

      puts "resource_refs:"
      m.resource_refs.each do |r|
        puts "* #{r.name} #{r.resources}"
      end

      puts "attributes"
      m.attributes.each do |a|
        puts "* #{a.name} #{a.type}"
      end

      puts "associations"
      m.associations.each do |assoc|
        puts "* #{assoc.inspect}"
      end
    end
  end

  # example do
  #   next
  #   resources = Fhir::Meta::Resource.all
  #   template = ERB.new(<<-RUBY, nil, '%<>-')
  # create_table '<%= model.full_name.pluralize.tableize %>' do |t|
  # <% model.attributes.each do |attr| -%>
  # t.column :<%= attr.name.underscore %> # <%= attr.type %> <%= attr.cardinality %>
  # <% end -%>
  # end
  #   RUBY
  #   resources.each do |res|
  #     res.models.each do |model|
  #       print template.result(binding)
  #     end
  #   end
  # end
end
