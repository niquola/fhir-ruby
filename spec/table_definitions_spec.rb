require 'spec_helper'

describe Fhir::TableDefinitions do
  let(:m) { Fhir::ElementsBuilder }
  let(:elements) do
    m.monadic(
      [
        m.element(%w[Person], type: 'Resource'),

        # Simple (singular)
        m.element(%w[Person name], type: 'string', max: '1'),
        m.element(%w[Person age], type: 'integer', max: '1'),
        # Simple (plural)
        m.element(%w[Person titles], type: 'string', max: '*'),

        # Complex (embedded, singular)
        m.element(%w[Person contactInfo], type: nil, max: '1'),
        m.element(%w[Person contactInfo phone], type: 'string', max: '1'),
        m.element(%w[Person contactInfo mailAddress], type: nil, max: '1'),
        m.element(%w[Person contactInfo mailAddress street], type: 'string', max: '1'),

        # Complex (embedded, plural)
        m.element(%w[Person addresses], type: nil, max: '*'),
        m.element(%w[Person addresses street], type: 'string', max: '1'),
        m.element(%w[Person addresses phones], type: nil, max: '*'),
        m.element(%w[Person addresses phones code], type: 'string', max: '1'),
        m.element(%w[Person addresses phones number], type: 'string', max: '1'),
        m.element(%w[Person addresses lines], type: nil, max: '1'),
        m.element(%w[Person addresses lines line1], type: 'string', max: '1'),

        # Complex (typed, singular)
        m.element(%w[Person workingHours], type: 'Range', max: '1'),

        # Complex (typed, plural)
        m.element(%w[Person identifier], type: 'Identifier', max: '*'),

        # Resource ref (singular)
        m.element(%w[Person organization], type: 'Resource(Organization)', max: '1'),
        m.element(%w[Person guarantor], type: 'Resource(Person|Organization)', max: '1'),

        # Resource ref (plural)
        m.element(%w[Person employees], type: 'Resource(Person)', max: '*'),
        m.element(%w[Person property], type: 'Resource(Any)', max: '*'),

        m.element(%w[Organization], type: 'Resource'),
        m.element(%w[Organization name], type: 'string', max: '1')
      ]
    ).set_simple_attribute.expand_with_datatypes
  end

  let(:person_table_definition) do
    elements.resource_tables.select_table('people')[0]
  end

  let(:title_table_definition) do
    elements.resource_tables.select_table('person_titles')[0]
  end

  let(:addresses_table_definition) do
    elements.resource_tables.select_table('person_addresses')[0]
  end

  let(:addresses_phones_table_definition) do
    elements.resource_tables.select_table('person_addresses_phones')[0]
  end

  let(:identifiers_table_definition) do
    elements.resource_tables.select_table('person_identifiers')[0]
  end

  let(:organization_table_definition) do
    elements.resource_tables.select_table('organizations')[0]
  end

  let(:person_properties_table_definition) do
    elements.resource_tables.select_table('person_properties')[0]
  end


  it 'should have singular attributes' do
    person_table_definition.should have_column 'string', 'name'
    person_table_definition.should have_column 'integer', 'age'
  end

  it 'should create tables for plural attributes' do
    title_table_definition.should have_column 'string', 'value'
    title_table_definition.should have_reference 'person', polymorphic: nil
  end

  it 'should have singular complex attribute fields' do
    person_table_definition.should have_column 'string', 'contact_info__phone'
    person_table_definition.should have_column 'string', 'contact_info__mail_address__street'

    person_table_definition.should have_column 'decimal', 'working_hours__low__value'
  end

  it 'should have plural complex attribute fields' do
    addresses_table_definition.should have_column 'string', 'street'
    addresses_table_definition.should have_column 'string', 'lines__line1'
    addresses_table_definition.should have_reference 'person', polymorphic: nil

    addresses_phones_table_definition.should have_column 'string', 'code'
    addresses_phones_table_definition.should have_column 'string', 'number'

    identifiers_table_definition.should have_column 'string', 'key'
  end

  it 'should have resource references' do
    person_table_definition.should have_reference 'organization'
    organization_table_definition.should have_column 'string', 'name'
    person_table_definition.should have_reference 'guarantor', polymorphic: true
    person_properties_table_definition.should have_reference 'person', polymorphic: nil
    person_properties_table_definition.should have_reference 'property', polymorphic: true
  end

  RSpec::Matchers.define :have_reference do |name, opts = {}|
    match do |table_definition|
      table_definition && table_definition.references.any? do |r|
        r.name == name && opts.fetch(:table_name, r.table_name) == r.table_name &&
          opts.fetch(:polymorphic, r.polymorphic) == r.polymorphic
      end
    end
    failure_message_for_should do |table_definition|
      references = table_definition.references.map { |c| "#{c.name}{table_name: #{c.table_name}, polymorphic: #{c.polymorphic}" }.join(',')
      "#{table_definition.table_name}[#{references}] should include reference #{name}#{opts.inspect}"
    end
  end

  RSpec::Matchers.define :have_column do |type, name|
    match do |table_definition|
      table_definition &&
        table_definition.columns.any? { |c| c.name == name && c.type == type }
    end

    failure_message_for_should do |table_definition|
      columns = table_definition.columns.map { |c| "#{c.type} #{c.name}" }.join(',')
      "#{table_definition.table_name}[#{columns}] should include column [#{type} #{name}]"
    end
  end
end
