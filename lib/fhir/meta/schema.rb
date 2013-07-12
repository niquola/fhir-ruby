require 'nokogiri'

module Fhir
  module Meta
    module Schema
      class << self
        attr :document

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

        private

        def types
          @types ||= parse_types
        end


        def parse_types
          @document.xpath('//schema/complexType').map do |complex_type|
            Fhir::Meta::Datatype.new(complex_type)
          end
        end
      end
    end
  end
end
