require 'ostruct'

module Fhir
  class Cli
    def initialize
      self.instance_eval File.read('Fhirfile'), 'Fhirfile'
    end

    def configure(&block)
      @config = OpenStruct.new
      block.call(@config)
    end

    def generate(&block)
      load_meta
      monad = Fhir::ElementsBuilder.monadic
      monad.instance_eval(&block)
    end

    def load_meta
      Fhir::Resource.load(@config.fhir_xml)
      Fhir::Datatype.load(@config.datatypes_xsd)
    end
  end
end
