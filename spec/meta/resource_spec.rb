require 'spec_helper'

Fhir::Meta::Resource.load(FHIR_FILE)

describe "Fhir::Meta::Resource" do
  example do
    Fhir::Meta::Resource.all.should_not be_empty

    [Fhir::Meta::Resource.find('MedicationStatement'),
     Fhir::Meta::Resource.find('Condition')].each do |res|
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
end
