class Fhir::MedicationStatementMedicationPackageContent < Fhir::Base

  belongs_to :item,
    class_name: 'MedicationStatementMedicationPackageContentItem'



include Fhir::Composite
  class MedicationStatementMedicationPackageContentAmount
    include Fhir::Composite
    include Fhir::Composing

    composing_attribute :value
    composing_attribute :units
    composing_attribute :system_name
    composing_attribute :code
  end
  composing :amount, class_name: 'MedicationStatementMedicationPackageContentAmount'

end
