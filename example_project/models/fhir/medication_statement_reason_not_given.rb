class Fhir::MedicationStatementReasonNotGiven < Fhir::Base


  # @attribute: text string

include Fhir::Composite
  class MedicationStatementReasonNotGivenCoding
    include Fhir::Composite
    include Fhir::Composing

    composing_attribute :system_name
    composing_attribute :code
    composing_attribute :display
  end
  composing :coding, class_name: 'MedicationStatementReasonNotGivenCoding'

end
