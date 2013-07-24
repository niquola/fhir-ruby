require 'spec_helper'

describe 'Fhir::Selection' do
  module TestSelection
    def my_selection(selection)
      selection
    end
  end

  let(:graph) do
    Object.new.tap do |g|
      g.stub(:modules).and_return([TestSelection])
    end
  end

  example do
    initial_selection = Object.new
    selection = Fhir::Selection.new(graph, initial_selection)
    selection.should respond_to(:my_selection)
    selection.my_selection.should == selection
  end

  it 'should add two selections' do
    sum = Fhir::Selection.new(graph, [42]) + Fhir::Selection.new(graph, [7])
    sum.should be_a(Fhir::Selection)
    sum.to_a.should == [42, 7]
  end

  it 'should flatten' do
    Fhir::Selection.new(graph, [[42]]).flatten.to_a.should == [42]
  end
end

