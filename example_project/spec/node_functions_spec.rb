require 'spec_helper'

describe NodeFunctions do
  let(:selection) { Fhir.graph.selection }

  let(:medstatement) { selection.node(['MedicationStatement']) }
  let(:medication) { selection.node(['Medication']) }
  let(:dose) { selection.node(['MedicationStatement','dosage']) }
  let(:route) { selection.node(['MedicationStatement','dosage', 'route']) }
  let(:medstatement_patient) { selection.node(['MedicationStatement', 'patient']) }
  let(:patient) { selection.node(['Patient']) }
  let(:when_given_start) { selection.node(['MedicationStatement', 'whenGiven', 'start']) }


  example 'class_name' do
    medstatement.class_name.should == 'MedicationStatement'
    dose.class_name.should == 'MedicationStatementDosage'
    route.class_name.should == 'MedicationStatementDosageRoute'
  end

  example 'belongs_to' do
    selection
    .node(['MedicationStatement', 'medication', 'code', 'coding'])
    .belongs_to
  end

  example 'table_name' do
    medstatement.table_name.should == 'medication_statements'
    dose.table_name.should == 'medication_statement_dosages'
    route.table_name.should == 'medication_statement_dosage_routes'
  end

  example 'class_file_name' do
    route.class_file_name.should == 'medication_statement_dosage_route'
  end

  example 'references' do
    medstatement
    .references
    .to_a
    .map(&:name)
    .should =~ ["administrationDevice", "patient"]
  end

  example 'embedded_associations' do
    medstatement
    .embedded_associations
    .to_a
    .map(&:name)
    .should =~ %w[dosage reasonNotGiven]
  end

  example 'associations' do
    medstatement
    .associations
    .to_a
    .map(&:table_name).should =~ ["medication_statement_dosage_timing_events",
				  "medication_statement_dosages",
				  "medication_statement_medication_code_codings",
				  "medication_statement_medication_package_container_codings",
				  "medication_statement_medication_package_contents",
				  "medication_statement_medication_product_form_codings",
				  "medication_statement_medication_product_ingredients",
				  "medication_statement_reason_not_givens"]
  end

  example 'resource name' do
    medstatement_patient.resource_name.should == 'Patient'
  end

  example 'referenced resource' do
    medstatement_patient.referenced_resource.should == patient
  end

  example 'columns' do
    medstatement
    .columns
    .to_a
    .map{|n| n.column_name(medstatement)}
    .should =~ ["identifier__assigner__display",
		"identifier__assigner__reference",
		"identifier__assigner__type_name",
		"identifier__key",
		"identifier__label",
		"identifier__period__end",
		"identifier__period__start",
		"identifier__system_name",
		"language",
		"was_not_given",
		"when_given__end",
		"when_given__start",
		"medication__code__text",
		"medication__is_brand",
		"medication__kind",
		"medication__language",
		"medication__name",
		"medication__package__container__text",
		"medication__product__form__text"]
  end

  example 'model attributes' do
    medstatement
    .model_attributes
    .to_a
    .map(&:name)
    .should =~ %w[language wasNotGiven]
  end

  example 'embedded children' do
    medstatement
    .embedded_children
    .to_a
    .map(&:name)
    .should =~ %w[whenGiven identifier medication]
  end

  example 'column name' do
    when_given_start.column_name(medstatement).should == 'when_given__start'
  end

  example 'resource_ref?' do
    medication.resource_ref?.should be_false
    medstatement_patient.resource_ref?.should be_true
  end

  example 'has_identity?' do
    medication.has_identity?.should be_false
    medstatement.has_identity?.should be_true
  end
end
