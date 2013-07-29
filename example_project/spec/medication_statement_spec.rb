require 'spec_helper'
FHIR_SPEC_ROOT = File.dirname(__FILE__)

describe 'Medication Statement' do
  before :all do
    ActiveRecord::Base.establish_connection(YAML.load_file( FHIR_SPEC_ROOT + '/database.yml'))

    ActiveRecord::Schema.define do
      eval File.read(File.dirname(__FILE__) + '/../migrations/schema.rb')
    end
  end

  example do

    codings_attributes = [
      {
	system_name: 'rxnorm.info',
	code: '312961'
      },
      {
	system_name: 'ndc',
	code: '52959-989'
      }
    ]

    medication_attributes =  {
      name: 'Simvastatin 20 mg tablet',
      code_attributes: {
	text: 'Simvastatin 20 mg tablet',
	codings_attributes: codings_attributes
      }
    }

    identifier_attributes = {
      key: '321312',
      assigner_attributes: {
	type: 'hospital rx',
	display: 'Apteka'
      }
    }

    dosages_attributes = [
      {
	route_attributes: {
	  coding_attributes: {
	    system_name: 'snomed',
	    code: '3123213',
	    display: 'Oral'
	  }
	}
      }
    ]


    statement = Fhir::MedicationStatement.create(
      medication_attributes: medication_attributes,
      identifier_attributes: identifier_attributes,
      dosages_attributes: dosages_attributes
    )

    statement.medication.name.should == 'Simvastatin 20 mg tablet'
    statement.medication.code.text.should == 'Simvastatin 20 mg tablet'
    coding = statement.medication.code.codings
    coding.should have(2).items
    coding.to_a.find { |c| c.system_name == 'rxnorm.info' }.code.should == '312961'
    coding.to_a.find { |c| c.system_name == 'ndc' }.code.should == '52959-989'

    statement.dosages.first.route.coding.display.should == 'Oral'
  end
end
