require 'spec_helper'

describe Fhir::Path do
  let(:p) { Fhir::Path }

  example do
    path = p.new(%w[a b c])
    subpath = p.new(%w[a b c d e])
    relative_path = p.new(%w[d e])

    path.to_s.should == 'a.b.c'

    path.subpath?(subpath).should be_true
    path.include?(subpath).should be_true

    (subpath < path).should be_true
    (subpath > path).should be_false

    subpath.relative(path).should == relative_path

    -> {
      path.relative(subpath).should == relative_path
    }.should raise_error(/not subpath/)

    (subpath - path).should == relative_path

    path.concat(relative_path).should == subpath
    (path + relative_path).should == subpath

    new_path = path.dup
    new_path.to_a.should == path.to_a

  end
end
