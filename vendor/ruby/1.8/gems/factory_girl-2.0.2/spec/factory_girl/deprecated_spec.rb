require 'spec_helper'

describe "accessing an undefined method on Factory that is defined on FactoryGirl" do
  let(:method_name) { :aliases }
  let(:return_value) { 'value' }
  let(:args) { [1, 2, 3] }

  before do
    stub($stderr).puts
    stub(FactoryGirl, method_name).returns { return_value }

    @result = Factory.send(method_name, *args)
  end

  it "prints a deprecation warning" do
    $stderr.should have_received.puts(anything)
  end

  it "invokes that method on FactoryGirl" do
    FactoryGirl.should have_received.method_missing(method_name, *args)
  end

  it "returns the value from the method on FactoryGirl" do
    @result.should == return_value
  end
end

describe "accessing an undefined method on Factory that is not defined on FactoryGirl" do
  let(:method_name) { :magic_beans }

  before do
    stub($stderr).puts { raise "Don't print a deprecation warning" }

    begin
      Factory.send(method_name)
    rescue Exception => @raised
    end
  end

  it "raises a NoMethodError" do
    @raised.should be_a(NoMethodError)
  end
end

describe "accessing an undefined constant on Factory that is defined on FactoryGirl" do
  before do
    @result = Factory::VERSION
  end

  it "returns that constant on FactoryGirl" do
    @result.should == FactoryGirl::VERSION
  end
end

describe "accessing an undefined constant on Factory that is undefined on FactoryGirl" do
  it "raises a NameError for Factory" do
    begin
      Factory::BOGUS
    rescue Exception => exception
    end

    exception.should be_a(NameError)
    exception.message.should include("Factory::BOGUS")
  end
end

