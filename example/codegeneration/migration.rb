require 'active_support'

module Migration
  # reject :technical_elements do |el|
  #   %w[extension text contained comparator].include?(el.path.last)
  # end

  # def resource_tables(elements)
  #   monadic(elements).select_resources.table_definitions(elements).all
  # end

  # # complex, simple   simple -> (ref, attr) 
  # # simple/complex { complex:? }
  # # root/singular/multipe {cardinality}
  # # table: root + multipe
  # def tables(elements)
  #   select_root(elements) + select_multiple(elements)
  # end

  # def table_definitions(parent_elements, elements, opts = {})
  #   tables = []
  #   parent_elements.map do |parent|
  #     table = opts[:table] || make_element_table(tables, parent)
  #     base_path = opts[:base_path] || parent.path

  #     branch = monadic(elements).select_branch(parent.path)
  #     attributes = branch.select_attributes(parent.path)
  #     singular_attributes = attributes.select_singular
  #     plural_attributes = attributes.select_plural
  #     references = branch.select_children(parent.path).select_references

  #     branch_elements = branch.all

  #     if (back_reference = opts[:back_reference])
  #       table.references << back_reference
  #     end

  #     singular_attributes.select_simple.each do |attr|
  #       table.columns << ColumnDefinition.new(attr.type, (attr.path - base_path).to_a.map(&:underscore).join('__'))
  #     end

  #     plural_attributes.select_simple.all.map do |attr|
  #       attr_table = make_element_table(tables, attr)
  #       attr_table.columns << ColumnDefinition.new(attr.type, 'value')
  #       attr_table.references << ReferenceDefinition.new(base_path.last.underscore, table_name: table.table_name)
  #       attr_table
  #     end

  #     tables +=
  #       singular_attributes.reject_simple.table_definitions(branch_elements, table: table, base_path: base_path).all
  #     tables += plural_attributes.reject_simple.table_definitions(
  #       branch_elements, back_reference: ReferenceDefinition.new(base_path.first.underscore, table_name: table.table_name)).all
  #     references.select_singular.each do |reference|
  #       table.references << make_reference(reference, reference.path - base_path)
  #     end

  #     references.select_plural.each do |reference|
  #       reference_table = make_element_table(tables, reference)
  #       reference_table.references << make_reference(reference, reference.path[-1..-1])
  #       reference_table.references << ReferenceDefinition.new(base_path.last.underscore, table_name: table.table_name)
  #     end
  #   end
  #   tables
  # end

  # def make_reference(reference, path)
  #   opts = {}
  #   if %w[Resource Resource(Any) ResourceReference].include? reference.type
  #     opts[:polymorphic] = true
  #   else
  #     types = /^Resource\(([^)]+)\)$/.match(reference.type)[1].split('|')
  #     if types.size > 1
  #       opts[:polymorphic] = true
  #     else
  #       opts[:table_name] = types.first.tableize
  #     end
  #   end
  #   ReferenceDefinition.new(path.to_a.map(&:underscore).join('__'), opts)
  # end

  # select :table do |element, table_name|
  #   element.table_name == table_name
  # end

  # class TableDefinition
  #   attr_reader :columns
  #   attr_reader :table_name
  #   attr_accessor :references

  #   def initialize(table_name)
  #     @table_name = table_name
  #     @columns = []
  #     @references = []
  #   end
  # end

  # class ColumnDefinition
  #   attr_reader :type, :name

  #   def initialize(type, name)
  #     @type = type
  #     @name = name
  #   end
  # end

  # class ReferenceDefinition
  #   attr_reader :name, :table_name, :polymorphic

  #   def initialize(name, opts = {})
  #     @name = name
  #     @polymorphic = opts[:polymorphic]
  #     @table_name = opts.fetch(:table_name) { @name.tableize }
  #   end
  # end

  # private

  # def make_element_table(scheme, element)
  #   table = TableDefinition.new(generate_table_name(element.path))
  #   scheme << table
  #   table
  # end

  # def generate_table_name(path)
  #   (path[0...-1].to_a.map(&:underscore) + [path.last.tableize]).join('_')
  # end
end
