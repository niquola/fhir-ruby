require 'spec_helper'

Fhir::Meta::Resource.load(FHIR_FILE)

describe "Fhir::Meta::Resource" do
  example do
    Fhir::Meta::Resource.all
  end
end
