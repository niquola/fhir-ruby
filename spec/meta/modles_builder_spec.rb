require 'spec_helper'
require "erb"

Fhir::Meta::Resource.load(FHIR_FILE)
file_name = File.join(File.dirname(__FILE__), '..', '..', 'fhir-base.xsd')
Fhir::Meta::Datatype.load(file_name)

describe "Fhir::Meta::ModelsBuilder" do
  let(:builder) { Fhir::Meta::ModelsBuilder.new }
  # example do
  #   models = builder.build
  #   medication_statment = models.find do |m|
  #     m.full_name == "MedicationStatement"
  #   end
  #   medication_statment.should_not be_nil
  #   medication_statment_dosage = models.find do |m|
  #     m.full_name == "MedicationStatementDosage"
  #   end
  #   medication_statment_dosage.should_not be_nil

  #   attr = medication_statment.attributes.find do |a|
  #     a.name == 'was_not_given'
  #   end
  #   attr.should_not be_nil
  #   attr.type.should == 'boolean'
  # end

  # example do
  #   identifier = builder.build.find do |m|
  #     m.full_name == "MedicationStatementIdentifier"
  #   end
  #   identifier.attributes.size.should == 3
  # end

  example do
    builder.build.each do |m|
      puts '-'*20
      puts m.full_name
      m.attributes.each do |a|
        puts "* #{a.name} #{a.type}"
      end
    end
  end

  # example do
  #   Fhir::Meta::Resource.all.should_not be_empty

  #   resources = Fhir::Meta::Resource.all
  #   resources = [Fhir::Meta::Resource.find('MedicationStatement')]

  #   resources.each do |res|
  #     res.models.each do |model|
  #       p model.full_name
  #       model.attributes.each do |attr|
  #         puts "* #{attr.name}"
  #       end
  #     end
  #   end
  # end

  # example do
  #   next
  #   Fhir::Meta::Resource.all.should_not be_empty

  #   resources = [Fhir::Meta::Resource.find('MedicationStatement'), Fhir::Meta::Resource.find('Condition')]
  #   resources = Fhir::Meta::Resource.all

  #   resources.each do |res|
  #     res.models.each do |model|
  #       puts
  #       puts model.full_name
  #       puts " attributes:"
  #       model.attributes.each do |attr|
  #         puts "   * #{attr.name} #{attr.cardinality}: #{attr.type}"
  #       end

  #       unless model.resource_refs.empty?
  #         puts " resources:"
  #         model.resource_refs.each do |attr|
  #           puts "   * #{attr.name} #{attr.cardinality} #{attr.type}"
  #         end
  #       end

  #       unless model.associations.empty?
  #         puts " associations:"
  #         model.associations.each do |attr|
  #           puts "   * #{attr.name} #{attr.cardinality}"
  #         end
  #       end

  #       puts '-' * 20
  #     end
  #   end
  # end

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
