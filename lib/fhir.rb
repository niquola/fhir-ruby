$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))
module Fhir
  autoload :Meta, 'fhir/meta'

end
