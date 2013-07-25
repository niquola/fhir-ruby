class Fhir::Base < ActiveRecord::Base
  self.table_name_prefix = 'fhir.'
  self.abstract_class = true
end
