require 'spec_helper'
require 'active_support'
require 'active_support/inflector'
require "erb"

Fhir::Meta::Resource.load(FHIR_FILE)
file_name = File.join(File.dirname(__FILE__), '..', '..', 'fhir-base.xsd')
Fhir::Meta::Datatype.load(file_name)

describe "Fhir::Meta::Resource" do
  example do
    resource = Fhir::Meta::Resource.find('MedicationStatement')
    resource.models.length.should == 2
  end

  example do
    Fhir::Meta::Resource.all.should_not be_empty

    resources = [Fhir::Meta::Resource.find('MedicationStatement'), Fhir::Meta::Resource.find('Condition')]
    resources = Fhir::Meta::Resource.all

    next
    resources.each do |res|
      res.models.each do |model|
        puts
        puts model.full_name
        puts " attributes:"
        model.attributes.each do |attr|
          puts "   * #{attr.name} #{attr.cardinality}: #{attr.type}"
        end

        unless model.resource_refs.empty?
          puts " resources:"
          model.resource_refs.each do |attr|
            puts "   * #{attr.name} #{attr.cardinality} #{attr.type}"
          end
        end

        unless model.associations.empty?
          puts " associations:"
          model.associations.each do |attr|
            puts "   * #{attr.name} #{attr.cardinality}"
          end
        end

        puts '-' * 20
      end
    end
  end

  example do
    resources = Fhir::Meta::Resource.all
    template = ERB.new(<<-RUBY, nil, '%<>-')

create_table '<%= model.full_name.pluralize.tableize %>' do |t|
<% model.attributes.each do |attr| -%>
  t.column :<%= attr.name.underscore %> # <%= attr.type %>
<% end -%>
end
    RUBY
    resources.each do |res|
      res.models.each do |model|
        print template.result(binding)
      end
    end
  end
end
