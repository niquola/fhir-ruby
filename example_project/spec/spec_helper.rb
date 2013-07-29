# system  "bundle exec ../bin/fhir Fhirfile"
require 'active_support'
require 'active_record'
require 'active_support/core_ext'
require 'active_support/dependencies'


::FHIR_PATH = File.expand_path(File.dirname(__FILE__))

$:.unshift(File.expand_path('../../lib', FHIR_PATH)) #include fhir
require 'fhir'

%w[models lib gen].each do |folder|
  ActiveSupport::Dependencies.autoload_paths << "#{FHIR_PATH}/../#{folder}"
end

Fhir.configure do |cfg|
  cfg.fhir_xml = FHIR_PATH + '/../../spec/tmp/cache.xml'
  cfg.datatypes_xsd = FHIR_PATH + '/../../fhir-base.xsd'
  cfg.node_modules = [NodeFunctions]
  cfg.selection_modules = [SelectionFunctions]
end

Rules.apply(Fhir.graph)
ExpandGraph.new(Fhir.graph).expand
