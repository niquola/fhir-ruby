require 'spec_helper'

describe 'Fhir::Node' do
  module NodeRole
    def children(node, selection, *args)
      node
    end
  end

  example do
    graph = Object.new
    graph.stub(:node_modules).and_return([NodeRole])
    graph.stub(:selection).and_return([NodeRole])

    node = Fhir::Node.new(graph, ['a','b'], prop: 'val')

    node.name.should == 'b'
    node.path.should be_a(Fhir::Path)

    node.should respond_to(:children)

    node.children.should == node
  end
end

