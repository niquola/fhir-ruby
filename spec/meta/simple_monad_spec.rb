require 'spec_helper'

describe Fhir::Meta::SimpleMonad do
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

  let(:monad) { m.new(%w[1 2 3 4 5 6 7], [ListOperations]) }

  example do
    ods = monad.odd
    ods.resolve.should == %w[1 3 5 7]
    ods.odd.resolve.should == %w[1 5]
  end

  example do
    ods = monad.select{|i| i == '7'}.resolve.should == %w[7]
  end
end
