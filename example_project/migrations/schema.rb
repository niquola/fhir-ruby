execute "drop schema fhir cascade; create schema fhir;"
create_table 'fhir.medication_statements' do |t|
  t.belongs_to :patient
  t.belongs_to :administration_device
  t.string :language
  t.boolean :was_not_given
  t.string :identifier__label
  t.string :identifier__system_name
  t.string :identifier__key
  t.datetime :identifier__period__start
  t.datetime :identifier__period__end
  t.string :identifier__assigner__type
  t.string :identifier__assigner__reference
  t.string :identifier__assigner__display
  t.datetime :when_given__start
  t.datetime :when_given__end
  t.string :medication__language
  t.string :medication__name
  t.boolean :medication__is_brand
  t.string :medication__kind
  t.string :medication__code__text
  t.string :medication__product__form__text
  t.string :medication__package__container__text
end

create_table 'fhir.medication_statement_administration_devices' do |t|
end

create_table 'fhir.medication_statement_dosages' do |t|
  t.integer :timing__repeat__frequency
  t.decimal :timing__repeat__duration
  t.integer :timing__repeat__count
  t.datetime :timing__repeat__end
  t.string :site__text
  t.string :site__coding__system_name
  t.string :site__coding__code
  t.string :site__coding__display
  t.string :route__text
  t.string :route__coding__system_name
  t.string :route__coding__code
  t.string :route__coding__display
  t.string :method__text
  t.string :method__coding__system_name
  t.string :method__coding__code
  t.string :method__coding__display
  t.decimal :quantity__value
  t.string :quantity__units
  t.string :quantity__system_name
  t.string :quantity__code
  t.decimal :rate__numerator__value
  t.string :rate__numerator__units
  t.string :rate__numerator__system_name
  t.string :rate__numerator__code
  t.decimal :rate__denominator__value
  t.string :rate__denominator__units
  t.string :rate__denominator__system_name
  t.string :rate__denominator__code
  t.decimal :max_dose_per_period__numerator__value
  t.string :max_dose_per_period__numerator__units
  t.string :max_dose_per_period__numerator__system_name
  t.string :max_dose_per_period__numerator__code
  t.decimal :max_dose_per_period__denominator__value
  t.string :max_dose_per_period__denominator__units
  t.string :max_dose_per_period__denominator__system_name
  t.string :max_dose_per_period__denominator__code
end

create_table 'fhir.medication_statement_dosage_timing_events' do |t|
  t.datetime :start
  t.datetime :end
end

create_table 'fhir.medication_statement_medication_code_codings' do |t|
  t.string :system_name
  t.string :code
  t.string :display
end

create_table 'fhir.medication_statement_medication_package_container_codings' do |t|
  t.string :system_name
  t.string :code
  t.string :display
end

create_table 'fhir.medication_statement_medication_package_contents' do |t|
  t.belongs_to :item
  t.decimal :amount__value
  t.string :amount__units
  t.string :amount__system_name
  t.string :amount__code
end

create_table 'fhir.medication_statement_medication_product_form_codings' do |t|
  t.string :system_name
  t.string :code
  t.string :display
end

create_table 'fhir.medication_statement_medication_product_ingredients' do |t|
  t.belongs_to :item
  t.decimal :amount__numerator__value
  t.string :amount__numerator__units
  t.string :amount__numerator__system_name
  t.string :amount__numerator__code
  t.decimal :amount__denominator__value
  t.string :amount__denominator__units
  t.string :amount__denominator__system_name
  t.string :amount__denominator__code
end

create_table 'fhir.medication_statement_reason_not_givens' do |t|
  t.string :text
  t.string :coding__system_name
  t.string :coding__code
  t.string :coding__display
end
