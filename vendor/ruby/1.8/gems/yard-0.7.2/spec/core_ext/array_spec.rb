require File.dirname(__FILE__) + '/../spec_helper'

describe Array do
  describe '#place' do
    it "should create an Insertion object" do
      [].place('x').should be_kind_of(Insertion)
    end
    
    it "should allow multiple objects to be placed" do
      [1, 2].place('x', 'y', 'z').before(2).should == [1, 'x', 'y', 'z', 2]
    end
  end
end

