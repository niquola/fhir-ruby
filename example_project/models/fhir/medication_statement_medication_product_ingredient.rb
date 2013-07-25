class Fhir::MedicationStatementMedicationProductIngredient < Fhir::Base

  belongs_to :item,
    class_name: 'MedicationStatementMedicationProductIngredientItem'



include Fhir::Composite
  class MedicationStatementMedicationProductIngredientAmount
    include Fhir::Composite
    include Fhir::Composing
    class MedicationStatementMedicationProductIngredientAmountNumerator
      include Fhir::Composite
      include Fhir::Composing

      composing_attribute :value
      composing_attribute :units
      composing_attribute :system_name
      composing_attribute :code
    end
    composing :numerator, class_name: 'MedicationStatementMedicationProductIngredientAmountNumerator'

    class MedicationStatementMedicationProductIngredientAmountDenominator
      include Fhir::Composite
      include Fhir::Composing

      composing_attribute :value
      composing_attribute :units
      composing_attribute :system_name
      composing_attribute :code
    end
    composing :denominator, class_name: 'MedicationStatementMedicationProductIngredientAmountDenominator'

    composing_attribute :numerator__value
    composing_attribute :numerator__units
    composing_attribute :numerator__system_name
    composing_attribute :numerator__code
    composing_attribute :denominator__value
    composing_attribute :denominator__units
    composing_attribute :denominator__system_name
    composing_attribute :denominator__code
  end
  composing :amount, class_name: 'MedicationStatementMedicationProductIngredientAmount'

end
