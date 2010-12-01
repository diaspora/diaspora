require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Capybara::Session do
  context 'with culerity driver' do
    before(:all) do
      @session = Capybara::Session.new(:culerity, TestApp)
    end

    describe '#driver' do
      it "should be a culerity driver" do
        @session.driver.should be_an_instance_of(Capybara::Driver::Culerity)
      end
    end

    describe '#mode' do
      it "should remember the mode" do
        @session.mode.should == :culerity
      end
    end

    it_should_behave_like "session"
    it_should_behave_like "session with javascript support"
    it_should_behave_like "session with headers support"
    it_should_behave_like "session with status code support"
  end
end
