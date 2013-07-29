require 'spec_helper'

describe 'Condition' do
  before :all do
    ActiveRecord::Base.establish_connection(YAML.load_file( FHIR_SPEC_ROOT + '/database.yml'))

    ActiveRecord::Schema.define do
      eval File.read(File.dirname(__FILE__) + '/../migrations/schema.rb')
    end
  end

  example do
    codeable_concept_attributes = {
      text: 'code text'
    }

    evidence = Fhir::ConditionEvidence.new(code_attributes: codeable_concept_attributes)
    location = Fhir::ConditionLocation.new(code_attributes: codeable_concept_attributes)
    related_item = Fhir::ConditionRelatedItem.new(type: 'follows', code_attributes: codeable_concept_attributes)

    condition = Fhir::Condition.create!(
      date_asserted: Time.zone.now,
      code_attributes: codeable_concept_attributes,
      category_attributes: codeable_concept_attributes,
      status: 'working',
      certainty_attributes: codeable_concept_attributes,
      severity_attributes: codeable_concept_attributes,
      onset: Time.zone.now,
      abatement: false,
      stage_attributes: {
        summary_attributes: codeable_concept_attributes
      },
      notes: 'notes'
    )

    condition.evidences << evidence
    condition.locations << locations
    condition.related_items << related_item

    condition.status.should == 'working'
    condition.locations.first.code.text.should == 'code text'
    condition.stage.summary.text.should == 'code text'
  end
end
