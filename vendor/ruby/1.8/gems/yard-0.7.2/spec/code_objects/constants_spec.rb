require File.dirname(__FILE__) + '/spec_helper'

describe YARD::CodeObjects, "CONSTANTMATCH" do
  it "should match a constant" do
    "Constant"[CodeObjects::CONSTANTMATCH].should == "Constant"
    "identifier"[CodeObjects::CONSTANTMATCH].should be_nil
    "File.new"[CodeObjects::CONSTANTMATCH].should == "File"
  end
end

describe YARD::CodeObjects, "NAMESPACEMATCH" do
  it "should match a namespace (multiple constants with ::)" do
    "Constant"[CodeObjects::NAMESPACEMATCH].should == "Constant"
    "A::B::C.new"[CodeObjects::NAMESPACEMATCH].should == "A::B::C"
  end
end

describe YARD::CodeObjects, "METHODNAMEMATCH" do
  it "should match a method name" do
    "method"[CodeObjects::METHODNAMEMATCH].should == "method"
    "[]()"[CodeObjects::METHODNAMEMATCH].should == "[]"
    "-@"[CodeObjects::METHODNAMEMATCH].should == "-@"
    "method?"[CodeObjects::METHODNAMEMATCH].should == "method?"
    "method!!"[CodeObjects::METHODNAMEMATCH].should == "method!"
  end
end

describe YARD::CodeObjects, "METHODMATCH" do
  it "should match a full class method path" do
    "method"[CodeObjects::METHODMATCH].should == "method"
    "A::B::C.method?"[CodeObjects::METHODMATCH].should == "A::B::C.method?"
    "A::B::C :: method"[CodeObjects::METHODMATCH].should == "A::B::C :: method"
    "SomeClass . method"[CodeObjects::METHODMATCH].should == "SomeClass . method"
  end
  
  it "should match self.method" do
    "self :: method!"[CodeObjects::METHODMATCH].should == "self :: method!"
    "self.is_a?"[CodeObjects::METHODMATCH].should == "self.is_a?"
  end
end

describe YARD::CodeObjects, "BUILTIN_EXCEPTIONS" do
  it "should include all base exceptions" do
    YARD::CodeObjects::BUILTIN_EXCEPTIONS.each do |name|
      eval(name).should <= Exception
    end
  end
end

describe YARD::CodeObjects, "BUILTIN_CLASSES" do
  it "should include all base classes" do
    YARD::CodeObjects::BUILTIN_CLASSES.each do |name|
      next if name == "MatchingData" && !defined?(::MatchingData)
      eval(name).should be_instance_of(Class)
    end
  end
  
  it "should include all exceptions" do
    YARD::CodeObjects::BUILTIN_EXCEPTIONS.each do |name|
      YARD::CodeObjects::BUILTIN_CLASSES.should include(name)
    end
  end
end

describe YARD::CodeObjects, "BUILTIN_ALL" do
  it "should include classes modules and exceptions" do
    a = YARD::CodeObjects::BUILTIN_ALL 
    b = YARD::CodeObjects::BUILTIN_CLASSES
    c = YARD::CodeObjects::BUILTIN_MODULES
    a.should == b+c
  end
end

describe YARD::CodeObjects, "BUILTIN_MODULES" do
  it "should include all base modules" do
    YARD::CodeObjects::BUILTIN_MODULES.each do |name|
      next if RUBY19 && ["Precision"].include?(name)
      eval(name).should be_instance_of(Module)
    end
  end
end