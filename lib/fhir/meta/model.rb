module Fhir
  module Meta
    class Model
      class << self
        def all
          @all ||= []
        end
      end

      attr :path

      def initialize(path)
        @path = path
      end

      attr_accessor :attributes

      def name
        @name ||= path.last.camelize
      end

      def full_name
        path.map(&:camelize).join('')
      end
    end
  end
end
