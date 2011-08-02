require File.dirname(__FILE__) + '/spec_helper'

describe YARD::Handlers::Processor do
  before do
    @proc = Handlers::Processor.new
  end
  
  it "should start with public visibility" do
    @proc.visibility.should == :public
  end
  
  it "should start in instance scope" do
    @proc.scope.should == :instance
  end
  
  it "should start in root namespace" do
    @proc.namespace.should == Registry.root
  end
  
  it "should have a globals structure" do
    @proc.globals.should be_a(OpenStruct)
  end
end