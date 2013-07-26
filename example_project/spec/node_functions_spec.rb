require 'spec_helper'

describe NodeFunctions do
  let(:selection) { Fhir.graph.selection }

  let(:medstatment) { selection.node(['MedicationStatement']) }
  let(:dose) {selection.node(['MedicationStatement','dosage']) }
  let(:route) {selection.node(['MedicationStatement','dosage', 'route']) }

  it 'class_name' do
    medstatment.class_name.should == 'MedicationStatement'
    dose.class_name.should == 'MedicationStatementDosage'
    route.class_name.should == 'MedicationStatementDosageRoute'
  end

  it 'table_name' do
    medstatment.table_name.should == 'medication_statements'
    dose.table_name.should == 'medication_statement_dosages'
    route.table_name.should == 'medication_statement_dosage_routes'
  end

  it 'class_file_name' do
    route.class_file_name.should == 'medication_statement_dosage_route'
  end

  it 'references' do
    medstatment
    .references
    .to_a
    .map(&:name)
    .should =~ ["administrationDevice", "medication", "patient"]
  end

  it 'embedded_associations' do
    medstatment
    .embedded_associations
    .to_a
    .map(&:name)
    .should =~ %w[identifier dosage reasonNotGiven]
  end

  it 'associations' do
    medstatment.associations.debug
  end
end
