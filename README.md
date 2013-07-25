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


Example:

```ruby
generate do |graph|
  models_folder = File.dirname(__FILE__)+ '/models/fhir'
  migrations_folder = File.dirname(__FILE__)+ '/migrations'
  FileUtils.rm_rf(models_folder)
  FileUtils.rm_rf(migrations_folder)
  FileUtils.mkdir_p(migrations_folder)

  graph.rule(%w[MedicationStatement dosage site coding],  max: '1')
  graph.rule(%w[MedicationStatement dosage route coding], max: '1')
  graph.rule(%w[MedicationStatement dosage method coding], max: '1')
  graph.rule(%w[MedicationStatement identifier], max: '1')
  graph.rule(%w[MedicationStatement reasonNotGiven coding], max: '1')
  graph.rule(%w[MedicationStatement medication], max: '1', embed: true)

  ExpandGraph.new(graph).expand


  branch = graph.selection.branch(['MedicationStatement'])
  .reject { |node| %w[contained extension].include?(node.name) }

  File.open(File.join(migrations_folder, 'schema.rb'), 'w') do |f|
    f.write  %Q[execute "drop schema fhir cascade; create schema fhir;"\n]
    f.write  branch.tables
    .template(path: "#{FHIR_PATH}/templates/migration.rb.erb")
    .render(0)
  end

  branch
  .models
  .template(path: "#{FHIR_PATH}/templates/model.rb.erb")
  .file(models_folder) {|n| "#{n.class_file_name}.rb" }
end

```

For more details see *example_project* direcotory.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
