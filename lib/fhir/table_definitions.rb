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
      path = opts[:path] || parent.path[1..-1]
      attributes = monadic(elements).select_attributes(parent.path)
      singular_attributes = attributes.select_singular
      plural_attributes = attributes.select_plural

      singular_attributes.select_simple.each do |attr|
        table.columns << ColumnDefinition.new(attr.type, (path + attr.path[-1..-1]).to_a.map(&:underscore).join('__'))
      end

      plural_attributes.select_simple.each do |attr|
        table_name = "#{parent.path.last.underscore}_#{attr.path.last.tableize}"
        attr_table = TableDefinition.new(table_name)
        attr_table.columns << ColumnDefinition.new(attr.type, 'value')
        scheme << attr_table
      end

      singular_attributes.reject_simple.each do |attr|
        monadic(elements).select_branch(attr.path).add_to_scheme(scheme, parent: attr, table: table,
                                                                 path: path + attr.path[-1..-1])
      end

      plural_attributes.reject_simple.each do |attr|
        table_name = (attr.path[0...-1].to_a.map(&:underscore) + [attr.path.last.tableize]).join('_')
        attr_table = TableDefinition.new(table_name)
        scheme << attr_table
        monadic(elements).select_branch(attr.path).add_to_scheme(scheme, table: attr_table, parent: attr,
                                                                 path: to_path([]))
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
