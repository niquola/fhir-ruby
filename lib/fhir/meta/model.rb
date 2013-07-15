module Fhir
  module Meta
    class Model
      class << self
        def all
          @all ||= []
        end
      end

      attr :path
      attr_accessor :parent

      def initialize(path)
        @path = path
      end

      attr_accessor :attributes

      def name
        @name ||= path.last.camelize
      end

      def full_name
        @name ||= path.map(&:camelize).join
      end

      def associations
        @associations ||= []
      end

      def resource_refs
        @resource_refs ||= []
      end
    end
  end
end
