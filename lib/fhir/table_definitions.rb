require 'active_support'

module Fhir
  module TableDefinitions
    include Dsl

    def table_definitions(elements)
      monadic(elements).select_resources.all.map do |resource|
        scheme = []
        resource_name = resource.path.last
        table = TableDefinition.new(resource_name.tableize)
        scheme << table
        monadic(elements).select_branch(resource.path).add_to_scheme(scheme, table: table, parent: resource)
        scheme
      end.flatten
    end

    def add_to_scheme(elements, scheme, opts = {})
      parent = opts[:parent]
      table = opts[:table]
      attributes = monadic(elements).select_attributes(parent.path)
      singular_attributes = attributes.select_singular
      plural_attributes = attributes.select_plural

      singular_attributes.select_simple.each do |attr|
        table.columns << ColumnDefinition.new(attr.type, attr.path[1..-1].to_a.join('__'))
      end

      singular_attributes.reject_simple.each do |attr|
        if attr.type.present?

        else
          monadic(elements).select_branch(attr.path).add_to_scheme(scheme, parent: attr, table: table)
        end
      end

      singular_attributes.select_complex.each do |attr|
        singular_attributes.select_branch(attr.path).add_to_scheme(scheme, parent: attr, table: table)
      end

      # plural_attributes.select_complex.each do |attr|
      #   table_name = "#{parent.path.last.underscore}_#{attr.path.last.tableize}"
      #   attr_table = TableDefinition.new(table_name)
      #   scheme << attr_table
      #   data_type = data_type_elements.select_branch([attr.type])
      #   data_type.add_to_scheme(scheme, table: attr_table, parent: data_type.root[0])
      # end

      plural_attributes.select_simple.each do |attr|
        table_name = "#{parent.path.last.underscore}_#{attr.path.last.tableize}"
        attr_table = TableDefinition.new(table_name)
        attr_table.columns << ColumnDefinition.new(attr.type, 'value')
        scheme << attr_table
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
  end
end
