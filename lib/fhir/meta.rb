module Fhir
  module Meta
    autoload :Resource, 'fhir/meta/resource'
    autoload :ActiveXml, 'fhir/meta/active_xml'
    autoload :Datatype, 'fhir/meta/datatype'
    autoload :Model, 'fhir/meta/model'
    autoload :Attribute, 'fhir/meta/attribute'
    autoload :Association, 'fhir/meta/association'
    autoload :ResourceRef, 'fhir/meta/resource_ref'
    autoload :ModelsBuilder, 'fhir/meta/models_builder'
    autoload :ElementsBuilder, 'fhir/meta/elements_builder'
  end
end
