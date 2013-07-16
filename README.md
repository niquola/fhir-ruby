# Fhir::Ruby

Code-Generation library for
Fast Healthcare Interoperability Resources (FHIR),
which defines a set of 'resources' to represent
health and healthcare administration-related information.

http://hl7.org/implement/standards/fhir/


## Installation

Add this line to your application's Gemfile:

    gem 'fhir-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fhir-ruby

## Usage

create code-generation file with following syntax and run *fhir myfile.rb* for codegeneration

```ruby

rules = {
  %w[MedicationStatement dosage site coding] => {max: '1'},
  %w[MedicationStatement dosage route coding] => {max: '1'},
  %w[MedicationStatement dosage method coding] => {max: '1'},
  %w[MedicationStatement identifier] => {max: '1'}
}

tables = resource_elements
.expand_with_datatypes
.filter_technical_elements
.filter_descendants(['MedicationStatement'])
.apply_rules(rules)
.tableize
.print do |el|
  p el.elements.send(:mod).methods
  el.elements.filter_simple_types
end


tables.template do
  <<-ERB
create_table <%= el.path.to_a.join('_').underscore %> do |t|
<% el.elements.filter_simple_types.each do |element| -%>
  t.string :<%= element.path.to_a.join('__').underscore %>
<% end -%>
end
  ERB
end
.print(&:code)

tables.template do
  <<-ERB
class <%= el.class_name %>
<% el.elements.filter_simple_types.each do |element| -%>
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

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
