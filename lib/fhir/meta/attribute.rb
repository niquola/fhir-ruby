module Fhir
  module Meta
    class Attribute
      attr :name
      attr :type

      def initialize(name, type)
        @name, @type = name, type
      end

      def to_sql_type
      end
    end
  end
end
