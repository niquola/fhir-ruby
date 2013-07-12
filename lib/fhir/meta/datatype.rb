require 'nokogiri'

module Fhir
  module Meta
    class Datatype
      SIMPLE_TYPES = %w[decimal integer boolean
        instant date base64Binary string uri
        dateTime id code oid uuid Element]

      def initialize(node)
        @node = node
      end

      def name
        @name ||= @node[:name]
      end

      def simple?
        return @simple unless @simple.nil?
        @simple = SIMPLE_TYPES.include?(name)
        @simple
      end

      def complex?
        ! simple?
      end

      def attributes
        return nil if simple?
        @attributes ||= parse_attributes
      end

      private

      def schema
        Fhir::Meta::Schema
      end

      def parse_attributes
        attributes = []
        @node.xpath('./complexContent/extension/sequence/element').each do |attribute|
          attributes << {
            name: attribute[:name] || attribute[:ref],
            type_name: attribute[:type] || attribute[:ref],
            type: schema.find(attribute[:type]),
            min: attribute[:minOccurs],
            max: attribute[:maxOccurs]
          }
        end
        attributes
      end
    end
  end
end
