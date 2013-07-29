require 'spec_helper'

describe SelectionFunctions do
  let(:selection) { Fhir.graph.selection }

  it "#value objects" do
    selection
    .branch(['MedicationStatement'])
    .value_objects
    .debug
  end
end
