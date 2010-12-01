require File.expand_path('../spec_helper', File.dirname(__FILE__))

if RUBY_PLATFORM =~ /java/
  describe Capybara::Driver::Celerity do
    before(:all) do
      @session = Capybara::Session.new(:celerity, TestApp)
    end

    describe '#driver' do
      it "should be a celerity driver" do
        @session.driver.should be_an_instance_of(Capybara::Driver::Celerity)
      end
    end

    describe '#mode' do
      it "should remember the mode" do
        @session.mode.should == :celerity
      end
    end

    it_should_behave_like "session"
    it_should_behave_like "session with javascript support"
    it_should_behave_like "session with headers support"
    it_should_behave_like "session with status code support"
  end
else
  puts "#{File.basename(__FILE__)} requires JRuby; skipping.."
end
