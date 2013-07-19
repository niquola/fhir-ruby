require 'active_support'

module Fhir
  module TableDefinitions
    extend ActiveSupport::Concern

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
      attributes.select_singular.all.each do |attr|
        table.columns << ColumnDefinition.new(attr.type, attr.path.last)
      end
      ## prefix = opts[:prefix] || ''

      #attributes = monadic([resource]).attributes
      #attributes.singular.each do |attr|
      #  table.columns << ColumnDefinition.new(attr.type, attr.name)
      #end
      #attributes.plural.each do |attr|
      #  scheme << (attr_table = TableDefinition.new("#{resource.name.underscore}_#{attr.name.tableize}"))
      #  # add_to_scheme(scheme, Identifier, table: 'medication_statement_identifiers')
      #  monadic([resource]).type.add_to_scheme(scheme, table: attr_table)
      #end
      #monadic([resource]).references.each do |ref|
      #  table.references << ColumnDefinition.new(nil, ref.name)
      #end
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