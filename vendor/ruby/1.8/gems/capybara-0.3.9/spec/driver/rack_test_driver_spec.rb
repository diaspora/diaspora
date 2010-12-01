require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Capybara::Driver::RackTest do
  before do
    @driver = Capybara::Driver::RackTest.new(TestApp)
  end

  it "should throw an error when no rack app is given" do
    running do
      Capybara::Driver::RackTest.new(nil)
    end.should raise_error(ArgumentError)
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with header support"
  it_should_behave_like "driver with status code support"
  it_should_behave_like "driver with cookies support"
  it_should_behave_like "driver with infinite redirect detection"
end
