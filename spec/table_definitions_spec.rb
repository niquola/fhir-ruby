require 'spec_helper'

describe Fhir::TableDefinitions do
  let(:m) { Fhir::ElementsBuilder }
  let(:elements) do
    m.monadic(
      [
        m.element(%w[Person], type: 'Resource'),

        m.element(%w[Person name], type: 'string', max: '1'),
        m.element(%w[Person age], type: 'integer', max: '1'),
        m.element(%w[Person titles], type: 'string', max: '*'),

        m.element(%w[Person contact_info], type: nil, max: '1'),
        m.element(%w[Person contact_info phone], type: 'string', max: '1'),

        m.element(%w[Person addresses], type: nil, max: '*'),
        m.element(%w[Person addresses street], type: 'string', max: '1'),

        m.element(%w[Person organization], type: 'Resource(Organization)', max: '1'),
        m.element(%w[Person employees], type: 'Resource(Person)', max: '*'),
      ]
    ).set_simple_attribute
  end

  let(:person_table_definition) do
    elements.select_branch(['Person']).table_definitions.select_table('people')[0]
  end

  let(:title_table_definition) do
    elements.select_branch(['Person']).table_definitions.select_table('person_titles')[0]
  end

  it 'should have singular attributes' do
    person_table_definition.should have_column 'string', 'name'
    person_table_definition.should have_column 'integer', 'age'
  end

  it 'should create tables for plural attributes' do
    title_table_definition.should have_column 'string', 'value'
  end

  it 'should have singular complex attribute fields' do
    person_table_definition.should have_column 'string', 'contact_info__phone'
  end

  RSpec::Matchers.define :have_column do |type, name|
    match do |table_definition|
      table_definition &&
        table_definition.columns.any? { |c| c.name == name && c.type == type }
    end
  end
end
