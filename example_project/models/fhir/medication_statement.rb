class Fhir::MedicationStatement < Fhir::Base

  belongs_to :patient,
    class_name: 'MedicationStatementPatient'

  belongs_to :administration_device,
    class_name: 'MedicationStatementAdministrationDevice'


  has_many :reason_not_givens,
    class_name: 'MedicationStatementReasonNotGiven'

  accepts_nested_attributes_for :reason_not_givens

  has_many :dosages,
    class_name: 'MedicationStatementDosage'

  accepts_nested_attributes_for :dosages

  has_many :medication__code__codings,
    class_name: 'MedicationStatementMedicationCodeCoding'

  accepts_nested_attributes_for :medication__code__codings

  has_many :medication__product__ingredients,
    class_name: 'MedicationStatementMedicationProductIngredient'

  accepts_nested_attributes_for :medication__product__ingredients

  has_many :medication__product__form__codings,
    class_name: 'MedicationStatementMedicationProductFormCoding'

  accepts_nested_attributes_for :medication__product__form__codings

  has_many :medication__package__contents,
    class_name: 'MedicationStatementMedicationPackageContent'

  accepts_nested_attributes_for :medication__package__contents

  has_many :medication__package__container__codings,
    class_name: 'MedicationStatementMedicationPackageContainerCoding'

  accepts_nested_attributes_for :medication__package__container__codings

  has_many :dosage__timing__events,
    class_name: 'MedicationStatementDosageTimingEvent'

  accepts_nested_attributes_for :dosage__timing__events

  # @attribute: language string
  # @attribute: was_not_given boolean

include Fhir::Composite
  class MedicationStatementIdentifier
    include Fhir::Composite
    include Fhir::Composing
    class MedicationStatementIdentifierPeriod
      include Fhir::Composite
      include Fhir::Composing

      composing_attribute :start
      composing_attribute :end
    end
    composing :period, class_name: 'MedicationStatementIdentifierPeriod'

    class MedicationStatementIdentifierAssigner
      include Fhir::Composite
      include Fhir::Composing

      composing_attribute :type
      composing_attribute :reference
      composing_attribute :display
    end
    composing :assigner, class_name: 'MedicationStatementIdentifierAssigner'

    composing_attribute :label
    composing_attribute :system_name
    composing_attribute :key
    composing_attribute :period__start
    composing_attribute :period__end
    composing_attribute :assigner__type
    composing_attribute :assigner__reference
    composing_attribute :assigner__display
  end
  composing :identifier, class_name: 'MedicationStatementIdentifier'

  class MedicationStatementWhenGiven
    include Fhir::Composite
    include Fhir::Composing

    composing_attribute :start
    composing_attribute :end
  end
  composing :whenGiven, class_name: 'MedicationStatementWhenGiven'

  class MedicationStatementMedication
    include Fhir::Composite
    include Fhir::Composing
    class MedicationStatementMedicationCode
      include Fhir::Composite
      include Fhir::Composing

      composing_attribute :text
      composing_attribute :codings_attributes
      composing_attribute :codings
    end
    composing :code, class_name: 'MedicationStatementMedicationCode'

    class MedicationStatementMedicationProduct
      include Fhir::Composite
      include Fhir::Composing
      class MedicationStatementMedicationProductForm
        include Fhir::Composite
        include Fhir::Composing

        composing_attribute :text
        composing_attribute :codings_attributes
        composing_attribute :codings
      end
      composing :form, class_name: 'MedicationStatementMedicationProductForm'

      composing_attribute :form__text
      composing_attribute :ingredients_attributes
      composing_attribute :ingredients
    end
    composing :product, class_name: 'MedicationStatementMedicationProduct'

    class MedicationStatementMedicationPackage
      include Fhir::Composite
      include Fhir::Composing
      class MedicationStatementMedicationPackageContainer
        include Fhir::Composite
        include Fhir::Composing

        composing_attribute :text
        composing_attribute :codings_attributes
        composing_attribute :codings
      end
      composing :container, class_name: 'MedicationStatementMedicationPackageContainer'

      composing_attribute :container__text
      composing_attribute :contents_attributes
      composing_attribute :contents
    end
    composing :package, class_name: 'MedicationStatementMedicationPackage'

    composing_attribute :language
    composing_attribute :name
    composing_attribute :is_brand
    composing_attribute :kind
    composing_attribute :code__text
    composing_attribute :product__form__text
    composing_attribute :package__container__text
  end
  composing :medication, class_name: 'MedicationStatementMedication'

end
