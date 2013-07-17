configure do |cfg|
  cfg.fhir_xml = path
  cfg.datatypes_xsd = path
end

resource_elements
.expand_with_datatypes
.select_technical_elements
.select_descendants(['MedicationStatement'])
.apply_rules(rules)
.tableize


tables.template do
  <<-ERB
create_table <%= el.path.join('_').underscore %> do |t|
<% el.elements.select_simple_types.each do |element| -%>
  t.string :<%= element.path.join('__').underscore %>
<% end -%>
end
  ERB
end.print(&:last)

tables.template do
  <<-ERB
class <%= el.class_name %>
<% el.elements.select_simple_types.each do |element| -%>
  # <%= element.attributes[:short] %>
  attr_accessor :<%= element.path.join('__').underscore %>
<% end -%>
<% el.elements.reject_singular.each do |element| -%>
  has_many :<%= element.path.last.underscore.pluralize %>
<% end -%>
end
  ERB
end
.file(File.dirname(__FILE__)+ '/models'){|el| el.path.join("_") + 'rb'}
.print(&:last)
