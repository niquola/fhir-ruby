require 'nokogiri'

module Fhir
  class Datatype
    class << self
      def load(path)
        @document = Nokogiri::XML(open(path).readlines.join(""))
        @document.remove_namespaces!
      end

      def all
        types
      end

      def find(name)
        types.select do |type|
          type.name == name
        end.first
      end

      def enum_values(type_name)
        enum_type = @document.xpath("//schema/simpleType[@name='#{type_name}']")
        enum_type.xpath('./restriction/enumeration').map { |node| node[:value] }
      end

      private

      def types
        @types ||= parse_types
      end

      def parse_types
        @document.xpath('//schema/complexType').map do |complex_type|
          self.new(complex_type)
        end
      end
    end

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
      @simple = SIMPLE_TYPES.include?(name) || enum?
    end

    def complex?
      ! simple?
    end

    def enum?
      return @enum unless @enum.nil?
      @node.xpath('./complexContent/extension/attribute').tap do |nodes|
        @enum = (nodes.size == 1 && !!(nodes.first[:type] =~ /-list$/))
      end
      @enum
    end

    def attributes
      return nil if simple?
      @attributes ||= parse_attributes
    end

    def enum_values
      return nil unless enum?
      simple_type = @node.xpath('./complexContent/extension/attribute').first[:type]
      self.class.enum_values(simple_type)
    end

    private

    class Attribute
      attr_accessor :name, :type, :type_name, :min, :max

      def initialize(attribute)
        @name = attribute[:name] || attribute[:ref]
        @type_name = attribute[:type] || attribute[:ref]
        @type = Datatype.find(attribute[:type])
        @min = attribute[:minOccurs]
        @max = attribute[:maxOccurs]
      end
    end

    def parse_attributes
      attributes = []
      @node.xpath('./complexContent/extension/sequence/element').each do |attribute|
        attributes << Attribute.new(attribute)
      end
      attributes
    end
  end
end
