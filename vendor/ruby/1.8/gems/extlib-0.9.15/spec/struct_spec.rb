require 'spec_helper'
require 'extlib/struct'

describe Struct do

  it "should have attributes" do

    s = Struct.new(:name).new('bob')
    s.attributes.should == { :name => 'bob' }

  end

end
