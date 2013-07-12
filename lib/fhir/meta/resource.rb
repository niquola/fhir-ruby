require 'nokogiri'

module Fhir
  module Meta
    class Resource
      class << self
        attr :source

        def load(path)
          @source = Nokogiri::XML(open(path).readlines.join(""))
        end

        def all
        end
      end
    end
  end
end
