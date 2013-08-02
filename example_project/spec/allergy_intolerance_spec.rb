require 'spec_helper'

describe 'AllergyIntolerance' do
  example do
    allergy = Fhir::AllergyIntolerance.create!(
      criticality: 'fatal',
      sensitivity_type: 'type',
      recorded_date: Time.now,
      status: 'status'
    )

    allergy.criticality.should == 'fatal'
    allergy.sensitivity_type.should == 'type'
    allergy.recorded_date.should be_within(10.seconds).of(Time.now)
    allergy.status.should == 'status'
  end
end
