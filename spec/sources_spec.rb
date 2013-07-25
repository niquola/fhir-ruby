require 'spec_helper'

describe 'Graph sources' do
  let(:graph) { Fhir.graph }
  let(:selection) { Fhir.graph.selection }

  it 'should parse xml data' do
    node = selection.node(['Condition'])
    node.max.should == '1'
    node.min.should == '1'
    node.attributes[:comment].should_not be_empty

    node.children.to_a.length.should == 22
  end

  it 'should expand datatypes' do
    node = selection.node(%w[Practitioner address])
    node.children.to_a.should_not be_empty
  end

  it 'should expand datatypes' do
    node = selection.node(%w[MedicationStatement identifier])
    # p Fhir.expand_datatypes(graph, node)
    # node.descendants.debug
  end
end
