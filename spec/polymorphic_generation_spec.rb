require 'spec_helper'

describe 'Polymorphic Generation' do
  let(:builder) { Fhir::ElementsBuilder }

  it 'should generate polymorphic models' do
    rules = {
      %w[MedicationStatement dosage site coding] => {max: '1'},
      %w[MedicationStatement dosage route coding] => {max: '1'},
      %w[MedicationStatement dosage method coding] => {max: '1'},
      %w[MedicationStatement identifier] => {max: '1'}
    }

    tables = builder.monadic
    .resource_elements
    .expand_with_datatypes
    .reject_technical_elements
    .select_descendants(['MedicationStatement'])
    .apply_rules(rules)
    .tableize
    .print do |el|
      p el.elements.send(:mod).methods
      el.elements.select_simple
    end


    tables.template do
      <<-ERB
create_table <%= el.path.to_a.join('_').underscore %> do |t|
<% el.elements.select_simple.each do |element| -%>
  t.string :<%= element.path.to_a.join('__').underscore %>
<% end -%>
end
      ERB
    end
    .print(&:code)

    tables.template do
      <<-ERB
class <%= el.class_name %>
<% el.elements.select_simple.each do |element| -%>
  attr_accessor :<%= element.path.to_a.join('__').underscore %>
<% end -%>
<% el.elements.reject_singular.each do |element| -%>
  has_many :<%= element.path.last.underscore.pluralize %>
<% end -%>
end
      ERB
    end
    .file(File.dirname(__FILE__)+ '/../tmp/models'){|el| el.path.to_a.join("_") + '.rb'}
    .print(&:code)
  end
end
