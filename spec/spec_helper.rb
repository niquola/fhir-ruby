require 'fhir'
require 'open-uri'

FHIR_URI = 'http://www.hl7.org/implement/standards/fhir/profiles-resources.xml'

FHIR_FILE = "#{File.dirname(__FILE__)}/tmp/cache.xml"

unless File.exists?(FHIR_FILE)
  f = open(FHIR_URI)
  FileUtils.mkdir_p(File.dirname(FHIR_FILE))
  File.open(FHIR_FILE, 'w') do |cf|
    cf << f.readlines.join("\n")
  end
end

Fhir::Resource.load(FHIR_FILE)
file_name = File.join(File.dirname(__FILE__), '..', 'fhir-base.xsd')
Fhir::Datatype.load(file_name)
