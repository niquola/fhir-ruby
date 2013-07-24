require 'spec_helper'

describe 'NodeFunctions' do
  let(:graph) do
    Fhir::Graph.new.tap do |g|
      g.add([1])
      g.add([1, 2])
      g.add([1, 2, 3])
      g.add([1, 2, 3, 4])
      g.add([1, 2, 3, 4, 5])
      g.add([1, 6])
    end
  end

  let(:selection) { graph.selection }
  let(:node) { selection.select { |n| n.path.to_a == [1, 2, 3] }.to_a.first }

  it 'should get children' do
    node.children.to_a.map(&:path).map(&:to_a).should =~ [[1, 2, 3, 4]]
  end

  it 'should get parents' do
    node.parent.path.to_a.should == [1, 2]
  end

  it 'should get ancestors' do
    node.ancestors.to_a.map(&:path).map(&:to_a).should =~ [[1], [1, 2]]
  end

  it 'should get descendants' do
    node.descendants.to_a.map(&:path).map(&:to_a).should =~
    [[1, 2, 3, 4], [1, 2, 3, 4, 5]]
  end
end
