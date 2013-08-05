require 'spec_helper'

describe 'Condition' do
  example do
    codeable_concept_attributes = {
      text: 'code text'
    }

    date = Time.now

    evidence_attrs = {code_attributes: codeable_concept_attributes}
    location_attrs = {detail: 'detail', code_attributes: codeable_concept_attributes}
    related_item_attrs = {type_name: 'follows', code_attributes: codeable_concept_attributes}

    condition = Fhir::Condition.create!(
      date_asserted: date,
      asserter_attributes: {
        name_attributes: { text: 'Roman' }
      },
      code_attributes: codeable_concept_attributes,
      category_attributes: codeable_concept_attributes,
      status: 'working',
      certainty_attributes: codeable_concept_attributes,
      severity_attributes: codeable_concept_attributes,
      onset: date,
      # abatement: false,
      stage_attributes: {
        summary_attributes: codeable_concept_attributes
      },
      notes: 'notes',
      evidences_attributes: [evidence_attrs],
      locations_attributes: [location_attrs],
      related_items_attributes: [related_item_attrs]
    )
    condition.save!
    condition.reload

    condition.date_asserted.should be_a(Date)
    condition.code.text.should == 'code text'
    condition.category.text.should == 'code text'
    condition.status.should == 'working'
    condition.certainty.text.should == 'code text'
    condition.severity.text.should == 'code text'
    condition.onset.should be_a(Date)
    # condition.abatement.should be_false
    condition.stage.summary.text.should == 'code text'
    condition.notes.should == 'notes'

    condition.evidences.first.code.text.should == 'code text'
    condition.locations.first.code.text.should == 'code text'
    condition.locations.first.detail.should == 'detail'
    p condition.related_items
    condition.related_items.first.code.text.should == 'code text'
    condition.related_items.first.type_name.should == 'follows'
  end
end
