require 'ostruct'

module Fhir
  class Cli
    def initialize
      self.instance_eval File.read('Fhirfile'), 'Fhirfile'
    end

    def configure(&block)
      Fhir.configure(&block)
    end

    def generate(&block)
      Fhir.generate(&block)
    end
  end
end
