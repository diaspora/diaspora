require File.dirname(__FILE__) + '/../spec_helper'

describe Module do
  describe '#class_name' do
    it "should return just the name of the class/module" do
      YARD::CodeObjects::Base.class_name.should == "Base"
    end
  end
  
  describe '#namespace' do
    it "should return everything before the class name" do
      YARD::CodeObjects::Base.namespace_name.should == "YARD::CodeObjects"
    end
  end
end