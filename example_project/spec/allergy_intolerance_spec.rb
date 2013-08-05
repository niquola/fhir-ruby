require 'spec_helper'

describe 'AllergyIntolerance' do
  example do
    allergy = Fhir::AllergyIntolerance.create!(
      criticality: 'fatal',
      sensitivity_type: 'allergy',
      recorded_date: Time.now,
      status: 'status',
      substance_attributes: {
        name: 'substance name',
        type_attributes: {
          text: 'aspirin',
          codings_attributes: [{system_name: 'RxNorm', code: '123456', display: 'aspirin'}]
        },
        description: 'substance description',
        status_attributes: { text: 'active' },
        effective_time_attributes: {
          start: Time.now,
          end: Time.now
        }
      },
      reactions_attributes: [{
        reaction_date: Time.now,
        did_not_occur_flag: false,
        symptoms_attributes: [{
          code_attributes: {text: 'pain'},
          severity: 'over 9000'
        }],
        exposures_attributes: [{
          exposure_date: Time.now,
          exposure_type: 'exposure type',
          causality_expectation: 'expectation code',
        }]
      }]
    )
    #TODO source of information
    #TODO value sets

    allergy.criticality.should == 'fatal'
    allergy.sensitivity_type.should == 'allergy'
    allergy.recorded_date.should be_within(10.seconds).of(Time.now)
    allergy.status.should == 'status'
    allergy.substance.first.type.codings.first.system_name.should == 'RxNorm'
  end
end
