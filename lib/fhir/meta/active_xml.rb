module Fhir
  module Meta
    class ActiveXml
      attr :node
      def initialize(node)
        @node = node
      end
    end
  end
end
