require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Capybara::Session do
  context 'with selenium driver' do
    before do
      @session = Capybara::Session.new(:selenium, TestApp)
    end

    describe '#driver' do
      it "should be a selenium driver" do
        @session.driver.should be_an_instance_of(Capybara::Driver::Selenium)
      end
    end

    describe '#mode' do
      it "should remember the mode" do
        @session.mode.should == :selenium
      end
    end

    it_should_behave_like "session"
    it_should_behave_like "session with javascript support"
    it_should_behave_like "session without headers support"
    it_should_behave_like "session without status code support"
  end
end
