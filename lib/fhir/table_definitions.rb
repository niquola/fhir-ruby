require 'active_support'

module Fhir
  module TableDefinitions
    include Dsl

    def table_definitions(elements)
      scheme = []
      monadic(elements).select_resources.add_to_scheme(scheme, elements)
      scheme
    end

    def add_to_scheme(parent_elements, scheme, elements, opts = {})
      parent_elements.each do |parent|
        table = opts[:table] || make_element_table(scheme, parent)
        base_path = opts[:base_path] || parent.path
        branch_elements = monadic(elements).select_branch(parent.path)
        attributes = branch_elements.select_attributes(parent.path)
        singular_attributes = attributes.select_singular
        plural_attributes = attributes.select_plural

        singular_attributes.select_simple.each do |attr|
          table.columns << ColumnDefinition.new(attr.type, (attr.path - base_path).to_a.map(&:underscore).join('__'))
        end

        plural_attributes.select_simple.each do |attr|
          attr_table = make_element_table(scheme, attr)
          attr_table.columns << ColumnDefinition.new(attr.type, 'value')
        end

        singular_attributes.reject_simple.
          add_to_scheme(scheme, branch_elements, table: table, base_path: base_path)

        plural_attributes.reject_simple.add_to_scheme(scheme, branch_elements)
      end
    end

    select :table do |element, table_name|
      element.table_name == table_name
    end

    class TableDefinition
      attr_reader :columns
      attr_reader :table_name
      attr_accessor :references

      def initialize(table_name)
        @table_name = table_name
        @columns = []
        @references = []
      end
    end

    class ColumnDefinition
      attr_reader :type, :name

      def initialize(type, name)
        @type = type
        @name = name
      end
    end

    private

    def make_element_table(scheme, element)
      table = TableDefinition.new(generate_table_name(element))
      scheme << table
      table
    end

    def generate_table_name(element)
      (element.path[0...-1].to_a.map(&:underscore) + [element.path.last.tableize]).join('_')
    end
  end
end
