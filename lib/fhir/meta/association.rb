module Fhir
  module Meta
    class Association
      attr :name
      attr :model_name
      attr :options

      def initialize(name, model_name, options)
        @name, @model_name, @options = name, model_name, options
      end
    end
  end
end

