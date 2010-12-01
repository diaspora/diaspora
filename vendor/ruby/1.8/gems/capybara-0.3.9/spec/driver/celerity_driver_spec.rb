require File.expand_path('../spec_helper', File.dirname(__FILE__))

if RUBY_PLATFORM =~ /java/
  describe Capybara::Driver::Celerity do
    before(:all) do
      @driver = Capybara::Driver::Celerity.new(TestApp)
    end

    it_should_behave_like "driver"
    it_should_behave_like "driver with javascript support"
    it_should_behave_like "driver with header support"
    it_should_behave_like "driver with status code support"
    it_should_behave_like "driver with cookies support"
  end
else
  puts "#{File.basename(__FILE__)} requires JRuby; skipping.."
end
