require 'spec_helper'

describe Fhir::SelecionFunctions do
  let(:graph) do
    Fhir::Graph.new.tap do |g|
      g.add([1])
      g.add([1, 2])
      g.add([1, 2, 3])
      g.add([1, 4])
    end
  end

  let(:selection) { graph.selection }

  it 'should debug' do
    selection.debug
  end

  it 'should select' do
    nodes = selection.select do |node|
      node.path.to_a.include?(2)
    end
    nodes.to_a.size.should == 2
  end

  it 'should select branch'  do
    selection.branch([1,4]).to_a.size.should == 1
    selection.branch([1,2]).to_a.size.should == 2
    selection.branch([1]).to_a.size.should == 4
  end

  it 'should select branches'  do
    selection.branches([1,4], [1,2,3])
    .to_a
    .map(&:path)
    .map(&:to_a)
    .should == [[1,4],[1,2,3]]
  end
end
