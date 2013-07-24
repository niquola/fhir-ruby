execute('drop schema if exists fhir cascade; create schema fhir')
create_table 'fhir.medication_statements' do |t|
  t.boolean :was_not_given
  t.IdentifierUse :identifier__use
  t.string :identifier__label
  t.uri :identifier__system
  t.string :identifier__key
  t.dateTime :identifier__period__start
  t.dateTime :identifier__period__end
  t.code :identifier__assigner__type
  t.string :identifier__assigner__reference
  t.string :identifier__assigner__display
  t.dateTime :when_given__start
  t.dateTime :when_given__end

  t.references :identifier__assigner, polymorphic: true
  t.references :patient
  t.references :medication
end

add_foreign_key 'fhir.medication_statements', 'fhir.patients', column_name: 'patient_id'
add_foreign_key 'fhir.medication_statements', 'fhir.medications', column_name: 'medication_id'


create_table 'fhir.medication_statement_reason_not_givens' do |t|

  t.references :medication_statement
end

add_foreign_key 'fhir.medication_statement_reason_not_givens', 'fhir.medication_statements', column_name: 'medication_statement_id'


create_table 'fhir.medication_statement_reason_not_given_codings' do |t|
  t.uri :system
  t.code :code
  t.string :display

  t.references :reason_not_given
end

add_foreign_key 'fhir.medication_statement_reason_not_given_codings', 'fhir.medication_statement_reason_not_givens', column_name: 'reason_not_given_id'


create_table 'fhir.medication_statement_dosages' do |t|
  t.integer :timing__repeat__frequency
  t.EventTiming :timing__repeat__when
  t.decimal :timing__repeat__duration
  t.UnitsOfTime :timing__repeat__units
  t.integer :timing__repeat__count
  t.dateTime :timing__repeat__end
  t.uri :site__coding__system
  t.code :site__coding__code
  t.string :site__coding__display
  t.uri :route__coding__system
  t.code :route__coding__code
  t.string :route__coding__display
  t.uri :method__coding__system
  t.code :method__coding__code
  t.string :method__coding__display
  t.decimal :quantity__value
  t.string :quantity__units
  t.uri :quantity__system
  t.code :quantity__code
  t.decimal :rate__numerator__value
  t.string :rate__numerator__units
  t.uri :rate__numerator__system
  t.code :rate__numerator__code
  t.decimal :rate__denominator__value
  t.string :rate__denominator__units
  t.uri :rate__denominator__system
  t.code :rate__denominator__code
  t.decimal :max_dose_per_period__numerator__value
  t.string :max_dose_per_period__numerator__units
  t.uri :max_dose_per_period__numerator__system
  t.code :max_dose_per_period__numerator__code
  t.decimal :max_dose_per_period__denominator__value
  t.string :max_dose_per_period__denominator__units
  t.uri :max_dose_per_period__denominator__system
  t.code :max_dose_per_period__denominator__code

  t.references :medication_statement
end

add_foreign_key 'fhir.medication_statement_dosages', 'fhir.medication_statements', column_name: 'medication_statement_id'


create_table 'fhir.medication_statement_dosage_timing_events' do |t|
  t.dateTime :start
  t.dateTime :end

  t.references :dosage
end

add_foreign_key 'fhir.medication_statement_dosage_timing_events', 'fhir.medication_statement_dosages', column_name: 'dosage_id'


create_table 'fhir.medication_statement_administration_devices' do |t|

  t.references :administration_device
  t.references :medication_statement
end

add_foreign_key 'fhir.medication_statement_administration_devices', 'fhir.devices', column_name: 'administration_device_id'
add_foreign_key 'fhir.medication_statement_administration_devices', 'fhir.medication_statements', column_name: 'medication_statement_id'
