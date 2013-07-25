class Fhir::MedicationStatementDosage < Fhir::Base


  has_many :timing__events,
    class_name: 'MedicationStatementDosageTimingEvent'

  accepts_nested_attributes_for :timing__events


include Fhir::Composite
  class MedicationStatementDosageTiming
    include Fhir::Composite
    include Fhir::Composing
    class MedicationStatementDosageTimingRepeat
      include Fhir::Composite
      include Fhir::Composing

      composing_attribute :frequency
      composing_attribute :duration
      composing_attribute :count
      composing_attribute :end
    end
    composing :repeat, class_name: 'MedicationStatementDosageTimingRepeat'

    composing_attribute :repeat__frequency
    composing_attribute :repeat__duration
    composing_attribute :repeat__count
    composing_attribute :repeat__end
    composing_attribute :events_attributes
    composing_attribute :events
  end
  composing :timing, class_name: 'MedicationStatementDosageTiming'

  class MedicationStatementDosageSite
    include Fhir::Composite
    include Fhir::Composing
    class MedicationStatementDosageSiteCoding
      include Fhir::Composite
      include Fhir::Composing

      composing_attribute :system_name
      composing_attribute :code
      composing_attribute :display
    end
    composing :coding, class_name: 'MedicationStatementDosageSiteCoding'

    composing_attribute :text
    composing_attribute :coding__system_name
    composing_attribute :coding__code
    composing_attribute :coding__display
  end
  composing :site, class_name: 'MedicationStatementDosageSite'

  class MedicationStatementDosageRoute
    include Fhir::Composite
    include Fhir::Composing
    class MedicationStatementDosageRouteCoding
      include Fhir::Composite
      include Fhir::Composing

      composing_attribute :system_name
      composing_attribute :code
      composing_attribute :display
    end
    composing :coding, class_name: 'MedicationStatementDosageRouteCoding'

    composing_attribute :text
    composing_attribute :coding__system_name
    composing_attribute :coding__code
    composing_attribute :coding__display
  end
  composing :route, class_name: 'MedicationStatementDosageRoute'

  class MedicationStatementDosageMethod
    include Fhir::Composite
    include Fhir::Composing
    class MedicationStatementDosageMethodCoding
      include Fhir::Composite
      include Fhir::Composing

      composing_attribute :system_name
      composing_attribute :code
      composing_attribute :display
    end
    composing :coding, class_name: 'MedicationStatementDosageMethodCoding'

    composing_attribute :text
    composing_attribute :coding__system_name
    composing_attribute :coding__code
    composing_attribute :coding__display
  end
  composing :method, class_name: 'MedicationStatementDosageMethod'

  class MedicationStatementDosageQuantity
    include Fhir::Composite
    include Fhir::Composing

    composing_attribute :value
    composing_attribute :units
    composing_attribute :system_name
    composing_attribute :code
  end
  composing :quantity, class_name: 'MedicationStatementDosageQuantity'

  class MedicationStatementDosageRate
    include Fhir::Composite
    include Fhir::Composing
    class MedicationStatementDosageRateNumerator
      include Fhir::Composite
      include Fhir::Composing

      composing_attribute :value
      composing_attribute :units
      composing_attribute :system_name
      composing_attribute :code
    end
    composing :numerator, class_name: 'MedicationStatementDosageRateNumerator'

    class MedicationStatementDosageRateDenominator
      include Fhir::Composite
      include Fhir::Composing

      composing_attribute :value
      composing_attribute :units
      composing_attribute :system_name
      composing_attribute :code
    end
    composing :denominator, class_name: 'MedicationStatementDosageRateDenominator'

    composing_attribute :numerator__value
    composing_attribute :numerator__units
    composing_attribute :numerator__system_name
    composing_attribute :numerator__code
    composing_attribute :denominator__value
    composing_attribute :denominator__units
    composing_attribute :denominator__system_name
    composing_attribute :denominator__code
  end
  composing :rate, class_name: 'MedicationStatementDosageRate'

  class MedicationStatementDosageMaxDosePerPeriod
    include Fhir::Composite
    include Fhir::Composing
    class MedicationStatementDosageMaxDosePerPeriodNumerator
      include Fhir::Composite
      include Fhir::Composing

      composing_attribute :value
      composing_attribute :units
      composing_attribute :system_name
      composing_attribute :code
    end
    composing :numerator, class_name: 'MedicationStatementDosageMaxDosePerPeriodNumerator'

    class MedicationStatementDosageMaxDosePerPeriodDenominator
      include Fhir::Composite
      include Fhir::Composing

      composing_attribute :value
      composing_attribute :units
      composing_attribute :system_name
      composing_attribute :code
    end
    composing :denominator, class_name: 'MedicationStatementDosageMaxDosePerPeriodDenominator'

    composing_attribute :numerator__value
    composing_attribute :numerator__units
    composing_attribute :numerator__system_name
    composing_attribute :numerator__code
    composing_attribute :denominator__value
    composing_attribute :denominator__units
    composing_attribute :denominator__system_name
    composing_attribute :denominator__code
  end
  composing :maxDosePerPeriod, class_name: 'MedicationStatementDosageMaxDosePerPeriod'

end
