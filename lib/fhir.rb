$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))
module Fhir
  autoload :Cli, 'fhir/cli'

  autoload :Resource, 'fhir/resource'
  autoload :ActiveXml, 'fhir/active_xml'
  autoload :Datatype, 'fhir/datatype'
  autoload :ElementsBuilder, 'fhir/elements_builder'
  autoload :Path, 'fhir/path'
  autoload :SimpleMonad, 'fhir/simple_monad'
  autoload :Element, 'fhir/element'
end
