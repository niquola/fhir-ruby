module Fhir
  module Meta
    class Element
      attr :path
      attr :attributes
      attr_accessor :elements

      def initialize(path, attributes)
        @path = path
        @attributes = attributes
      end

      def elements
        @elements ||= []
      end

      def method_missing(attr)
        if @attributes.key?(attr.to_sym)
          @attributes[attr.to_sym]
        else
          super
        end
      end

      def class_name
        path.join('_').camelize
      end

      def initialize_copy(origin)
        @path = origin.path.dup
        @attributes = origin.attributes.dup
      end
    end
  end
end
