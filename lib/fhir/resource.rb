require 'nokogiri'

module Fhir
  #Follow xml definition structure
  class Resource < Fhir::ActiveXml
    class Element < Fhir::ActiveXml
      def path
        value_from_path('path').split('.')
      end

      def definition
        @definition = Definition.new(node.xpath('./definition').first)
      end

      def name
        path.last
      end

      class Definition < Fhir::ActiveXml
        value_attr 'max'
        value_attr 'min'
        value_attr 'short'
        value_attr 'formal'
        value_attr 'comments'

        value_attr './type/code', 'type'
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

    value_attr 'type', 'name'
    value_attr 'type'

    def elements
      @elements ||= node
      .xpath('./element')
      .map{|n| Element.new(n) }
    end
  end
end
