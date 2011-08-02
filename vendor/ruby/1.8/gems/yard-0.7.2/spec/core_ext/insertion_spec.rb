require File.dirname(__FILE__) + '/../spec_helper'

describe Insertion do
  describe '#before' do
    it "should place an object before another" do
      [1, 2].place(3).before(2).should == [1, 3, 2]
      [1, 2].place(3).before(1).should == [3, 1, 2]
      [1, [4], 2].place(3).before(2).should == [1, [4], 3, 2]
    end
  end
  
  describe '#after' do
    it "should place an object after another" do
      [1, 2].place(3).after(2).should == [1, 2, 3]
    end

    it "should no longer place an object after another and its subsections (0.6)" do
      [1, [2]].place(3).after(1).should == [1, 3, [2]]
    end
    
    it "should place an array after an object" do
      [1, 2, 3].place([4]).after(1).should == [1, [4], 2, 3]
    end
  end
  
  describe '#before_any' do
    it "should place an object before another anywhere inside list (including sublists)" do
      [1, 2, [3]].place(4).before_any(3).should == [1, 2, [4, 3]]
    end
  end

  describe '#after_any' do
    it "should place an object after another anywhere inside list (including sublists)" do
      [1, 2, [3]].place(4).after_any(3).should == [1, 2, [3, 4]]
    end
  end
end
