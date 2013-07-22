require 'active_support'

module Fhir
  module TableDefinitions
    include Dsl

    def resource_tables(elements)
      monadic(elements).select_resources.table_definitions(elements)
    end

    def table_definitions(parent_elements, elements, opts = {})
      tables = []
      parent_elements.map do |parent|
        table = opts[:table] || make_element_table(tables, parent)
        base_path = opts[:base_path] || parent.path

        branch = monadic(elements).select_branch(parent.path)
        attributes = branch.select_attributes(parent.path)
        singular_attributes = attributes.select_singular
        plural_attributes = attributes.select_plural

        branch_elements = branch.all

        singular_attributes.select_simple.each do |attr|
          table.columns << ColumnDefinition.new(attr.type, (attr.path - base_path).to_a.map(&:underscore).join('__'))
        end

        plural_attributes.select_simple.all.map do |attr|
          attr_table = make_element_table(tables, attr)
          attr_table.columns << ColumnDefinition.new(attr.type, 'value')
          attr_table
        end

        tables +=
          singular_attributes.reject_simple.table_definitions(branch_elements, table: table, base_path: base_path).all
        tables += plural_attributes.reject_simple.table_definitions(branch_elements).all
      end
      tables
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
