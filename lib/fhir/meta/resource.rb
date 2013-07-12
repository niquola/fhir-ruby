require 'nokogiri'

module Fhir
  module Meta
    class Resource < Fhir::Meta::ActiveXml
      module Cardinality
        def min
          element.definition.min
        end

        def max
          element.definition.max
        end

        def multiple?
          max == '*'
        end

        def cardinality
          "#{min}-#{max}"
        end
      end

      class Attr
        include Cardinality
        attr :element
        def initialize(element)
          @element = element
        end

        def type
          element.definition.type
        end

        def name
          element.name
        end
      end

      class ResourceRef
        include Cardinality
        attr :element
        def initialize(element)
          @element = element
        end

        def type
          element.definition.type
        end

        def name
          element.name
        end
      end

      class Association
        include Cardinality
        attr :element

        def initialize(element)
          @element = element
        end

        def type
          element.definition.type
        end

        def name
          element.name
        end
      end

      class Model
        attr :path

        def initialize(path, elements)
          @path = path
          @elements = elements
        end

        def name
          @name ||= camelize(path.last)
        end

        def full_name
          path.map{|p| camelize(p)}.join('')
        end

        def attributes
          @attributes ||= @elements.map do |el|
            if el.definition.attribute? && belongs_to?(el.path)
              Attr.new(el)
            end
          end.compact
        end

        def resource_refs
          @resources ||= @elements.map do |el|
            if el.definition.reference? && belongs_to?(el.path)
              ResourceRef.new(el)
            end
          end.compact
        end

        def associations
          @associations ||= @elements.map do |el|
            if belongs_to?(el.path) && el.definition.type.nil?
              Association.new(el)
            end
          end.compact
        end

        private

        def belongs_to?(p)
          p.join('.') =~ /^#{path.join('.')}.+/
        end

        def camelize(str)
          str[0].upcase + str[1..-1]
        end
      end

      class << self
        attr :source

        def load(path)
          @source = Nokogiri::XML(open(path).readlines.join(""))
          @source.remove_namespaces!
        end

        def all
          resources
        end

        def find(name)
          resources.find{|r| r.name == name }
        end

        def resources
          @resources ||= source.xpath('//Profile/structure').map{|n| self.new(n)}
        end
      end

      def name
        node.xpath('./type').first[:value]
      end

      IGNORED_ATTRIBUTES = %[extension text contained]
      def elements
        @elements ||= node.xpath('./element')
        .map{|n| Element.new(n) }
        .select do |el|
          !IGNORED_ATTRIBUTES.include?(el.name.to_s)
        end
      end

      def models
        @models = elements.map do |el|
          if el.definition.model?
            Model.new(el.path, elements)
          end
        end.compact
      end
    end
  end
end
