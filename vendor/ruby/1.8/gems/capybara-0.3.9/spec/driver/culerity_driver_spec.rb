require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Capybara::Driver::Culerity do
  before(:all) do
    @driver = Capybara::Driver::Culerity.new(TestApp)
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"
  it_should_behave_like "driver with header support"
  it_should_behave_like "driver with status code support"
  it_should_behave_like "driver with cookies support"
end
