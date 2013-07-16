require 'spec_helper'

describe Fhir::Meta::Element do
  let(:e) { described_class }

  example do
    el = e.new(Fhir::Meta::Path.new(%w[a b c]), max: 1, min: 0)
    el.path.to_a.should == %w[a b c]

    el.min.should == 0
    el.max.should == 1

    el.elements.should == []
  end
end
