require 'ostruct'

module Fhir
  class Cli
    def initialize
      self.instance_eval File.read('Fhirfile')
    end

    def configure(&block)
      @config = OpenStruct.new
      block.call(@config)
    end

    def elements(&block)
      load_meta
      @elements = block.call(Fhir::Meta::ElementsBuilder
                             .monadic.resource_elements)
    end

    def load_meta
      Fhir::Meta::Resource.load(@config.fhir_xml)
      Fhir::Meta::Datatype.load(@config.datatypes_xsd)
    end
  end
end
