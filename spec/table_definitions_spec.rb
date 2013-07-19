require 'spec_helper'

describe Fhir::TableDefinitions do
  let(:m) { Fhir::ElementsBuilder }
  let(:elements) do
    m.monadic(
      [
        m.element(%w[Entity], type: 'Resource'),
        m.element(%w[Entity single_string], type: :string, max: '1'),
        m.element(%w[Entity multiple_strings], type: :string, max: '*'),
        m.element(%w[Entity ref], max: '*'),
        m.element(%w[Entity ref field2], type: :integer, max: '1')
      ]
    )
  end

  let(:table_definition) do
    elements.select_branch(['Entity']).table_definitions.all.first
  end

  it 'should have singular attributes' do
    table_definition.should have_column :string, 'single_string'
    table_definition.should_not have_column :string, 'multiple_string'
  end

  RSpec::Matchers.define :have_column do |type, name|
    match do |table_definition|
      table_definition.columns.any? { |c| c.name == name && c.type == type }
    end
  end
end