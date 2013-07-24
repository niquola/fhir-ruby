require 'spec_helper'

describe Fhir::Graph do
  subject {  Fhir::Graph.new(modules: Module.new, node_modules: Module.new) }

  it 'should add nodes' do
    subject.add(['one', 'two', 'three'])
    node = subject.nodes.first
    node.should be_a(Fhir::Node)
    node.path.should == ['one', 'two', 'three']
  end

  it 'should apply rules' do
    subject.add([42], max: 7)
    subject.rule([42], max: -1)
    node = subject.nodes.first
    node.max.should == -1
  end
end
