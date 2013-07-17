require 'spec_helper'
require 'active_support'
require 'active_support/inflector'

describe "Fhir::Resource" do

  example do
    resources = Fhir::Resource.all
    resources.length.should == 49
  end

  example do
    resource = Fhir::Resource.find("MedicationStatement")
    resource.name.should == "MedicationStatement"

    resource.elements.length.should == 19

    rate = resource.elements.find {|e| e.name == 'rate'}
    rate.should_not be_nil
    rate.definition.max.should == '1'
    rate.definition.min.should == '0'
    rate.definition.short.should == 'Dose quantity per unit of time'
    rate.definition.formal.should == 'Identifies the speed with which the substance is introduced into the subject. Typically the rate for an infusion. 200ml in 2 hours.'
    rate.definition.comments.should be_nil
    rate.definition.type.should == 'Ratio'
  end
end
