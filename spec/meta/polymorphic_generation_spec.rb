require 'spec_helper'

describe 'Polymorphic Generation' do
  let(:builder) { Fhir::Meta::ElementsBuilder }

  it 'should generate polymorphic models' do
    rules = {
      %w[MedicationStatement dosage site coding] => {max: '1'},
      %w[MedicationStatement dosage route coding] => {max: '1'},
      %w[MedicationStatement dosage method coding] => {max: '1'},
      %w[MedicationStatement identifier] => {max: '1'}
    }
    builder.monadic
    resource_elements
    .expand_with_datatypes
    .filter_technical_elements
    .filter_descendants(['MedicationStatement'])
    .apply_rules(rules)
    .modelize
    .reject_singular
    .template do
      <<-ERB
class <%= el.class_name %>
<% el.elements.filter_simple_types.each do |element| -%>
  attr_accessor :<%= element.path.last.underscore %>
<% end -%>
<% el.elements.reject_singular.each do |element| -%>
  has_many :<%= element.path.last.underscore.pluralize %>
<% end -%>
end
      ERB
    end.print(&:last)
  end
end
