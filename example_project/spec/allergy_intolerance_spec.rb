require 'spec_helper'

describe 'Condition' do
  before :all do
    ActiveRecord::Base.establish_connection(YAML.load_file( FHIR_SPEC_ROOT + '/database.yml'))

    ActiveRecord::Schema.define do
      eval File.read(File.dirname(__FILE__) + '/../migrations/schema.rb')
    end
  end

  example do
    allergy = Fhir::AllergyIntolerance.create!(
      criticality: 'fatal',
      sensitivity_type: 'type',
      recorded_date: Time.zone.now,
      status: 'status'
    )

    allergy.criticality.should == 'fatal'
    allergy.sensitivity_type.should == 'type'
    allergy.recorded_date.should be_within(10.seconds).of(Time.zone.now)
    allergy.status.should == 'status'
  end
end
