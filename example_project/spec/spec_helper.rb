require 'fhir'
require 'active_support'
require 'active_record'
require 'active_support/core_ext'
require 'active_support/dependencies'

%w[models lib codegeneration].each do |folder|
  ActiveSupport::Dependencies.autoload_paths << File.expand_path("../../#{folder}", __FILE__)
end

::FHIR_PATH = File.expand_path(File.dirname(__FILE__))
Fhir::Cli.configure do |cfg|
  cfg.fhir_xml = FHIR_PATH + '/../../spec/tmp/cache.xml'
  cfg.datatypes_xsd = FHIR_PATH + '/../../fhir-base.xsd'
  cfg.node_modules = [Tableize]
  cfg.selection_modules = [SelectionQueries]
end
