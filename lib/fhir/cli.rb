require 'ostruct'

module Fhir
  class Cli
    def initialize(file)
      raise "Could not find configuratin file - #{file}" unless File.exists?(file)
      self.instance_eval File.read(file), file
    end

    def configure(&block)
      Fhir.configure(&block)
    end

    def generate(&block)
      Fhir.generate(&block)
    end
  end
end
