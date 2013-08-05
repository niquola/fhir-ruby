require 'spec_helper'

describe SelectionFunctions do
  let(:selection) { Fhir.graph.selection }

  it "#value objects" do
    selection
    .branch(['MedicationStatement'])
    .value_objects
  end

  it 'should select tables' do
    selection
    .branch(['AllergyIntolerance'])
    .tables
    .to_a
    .map(&:table_name)
    .size.should == 21
  end
end
