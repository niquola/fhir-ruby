require 'spec_helper'

describe Fhir::Monad do
  let(:m) { described_class }

  module ListOperations
    def odd(list)
      res = []
      list.each_with_index do |item, index|
        if index % 2 == 0
          res<< item
        end
        res
      end
      res
    end

    def select(list, &block)
      list.select(&block)
    end
  end

  module Stoping
    def ending(elements)
      stop elements.join("|")
    end
  end

  let(:monad) { m.new(%w[1 2 3 4 5 6 7], [Stoping, ListOperations]) }

  example do
    ods = monad.odd

    ods.all
    .should == %w[1 3 5 7]

    ods.odd
    .all
    .should == %w[1 5]
  end

  it "should stop" do
    monad.odd
    .ending
    .should == '1|3|5|7'
  end

  example do
    monad.select{|i| i == '7'}
    .all
    .should == %w[7]
  end
end
