require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Capybara::Driver::Selenium do
  before(:all) do
    Capybara.app_host = "http://capybara-testapp.heroku.com"
  end
  
  after(:all) do
    Capybara.app_host = nil
  end

  before do
    @driver = Capybara::Driver::Selenium.new(TestApp)
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"
  it_should_behave_like "driver without status code support"
end