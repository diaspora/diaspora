require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'capybara/dsl'

describe Capybara do

  before do
    Capybara.app = TestApp
  end

  after do
    Capybara.default_driver = nil
    Capybara.use_default_driver
  end

  describe '#default_driver' do
    it "should default to rack_test" do
      Capybara.default_driver.should == :rack_test
    end

    it "should be changeable" do
      Capybara.default_driver = :culerity
      Capybara.default_driver.should == :culerity
    end
  end

  describe '#current_driver' do
    it "should default to the default driver" do
      Capybara.current_driver.should == :rack_test
      Capybara.default_driver = :culerity
      Capybara.current_driver.should == :culerity
    end

    it "should be changeable" do
      Capybara.current_driver = :culerity
      Capybara.current_driver.should == :culerity
    end
  end

  describe '#javascript_driver' do
    it "should default to selenium" do
      Capybara.javascript_driver.should == :selenium
    end

    it "should be changeable" do
      Capybara.javascript_driver = :culerity
      Capybara.javascript_driver.should == :culerity
    end
  end

  describe '#use_default_driver' do
    it "should restore the default driver" do
      Capybara.current_driver = :culerity
      Capybara.use_default_driver
      Capybara.current_driver.should == :rack_test
    end
  end

  describe '#app' do
    it "should be changeable" do
      Capybara.app = "foobar"
      Capybara.app.should == 'foobar'
    end
  end

  describe '#current_session' do
    it "should choose a session object of the current driver type" do
      Capybara.current_session.should be_a(Capybara::Session)
    end

    it "should use #app as the application" do
      Capybara.app = proc {}
      Capybara.current_session.app.should == Capybara.app
    end

    it "should change with the current driver" do
      Capybara.current_session.mode.should == :rack_test
      Capybara.current_driver = :culerity
      Capybara.current_session.mode.should == :culerity
    end

    it "should be persistent even across driver changes" do
      object_id = Capybara.current_session.object_id
      Capybara.current_session.object_id.should == object_id
      Capybara.current_driver = :culerity
      Capybara.current_session.mode.should == :culerity
      Capybara.current_session.object_id.should_not == object_id

      Capybara.current_driver = :rack_test
      Capybara.current_session.object_id.should == object_id
    end

    it "should change when changing application" do
      object_id = Capybara.current_session.object_id
      Capybara.current_session.object_id.should == object_id
      Capybara.app = proc {}
      Capybara.current_session.object_id.should_not == object_id
      Capybara.current_session.app.should == Capybara.app
    end
  end

  describe '.reset_sessions!' do
    it "should clear any persisted sessions" do
      object_id = Capybara.current_session.object_id
      Capybara.current_session.object_id.should == object_id
      Capybara.reset_sessions!
      Capybara.current_session.object_id.should_not == object_id
    end
  end

  describe 'the DSL' do
    before do
      @session = Capybara
    end

    it_should_behave_like "session"
    it_should_behave_like "session without javascript support"

    it "should be possible to include it in another class" do
      klass = Class.new do
        include Capybara
      end
      foo = klass.new
      foo.visit('/with_html')
      foo.click_link('ullamco')
      foo.body.should include('Another World')
    end

    it "should provide a 'page' shortcut for more expressive tests" do
      klass = Class.new do
        include Capybara
      end
      foo = klass.new
      foo.page.visit('/with_html')
      foo.page.click_link('ullamco')
      foo.page.body.should include('Another World')
    end
  end

end
