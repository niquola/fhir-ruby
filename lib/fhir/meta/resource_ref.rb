module Fhir
  module Meta
    class ResourceRef
      attr :name
      attr :type

      def initialize(name, type)
        @name, @type = name, type
      end

      def polymorphic?
        resources.length > 1 || type == 'Resource(Any)'
      end

      def resources
        @resources ||= type.gsub(/^Resource\(/,'').gsub(/\)$/,'').split('|')
      end
    end
  end
end
