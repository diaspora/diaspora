require 'spec_helper'
require 'cucumber/wire_support/wire_language'

module Cucumber
  module WireSupport
    describe WireLanguage do
      def stub_wire_file!(filename, config)
        Configuration.stub!(:new).with(filename).and_return config
      end
      
      describe "#load_code_file" do
        before(:each) do
          stub_wire_file! 'foo.wire', :config
        end
      
        it "creates a RemoteSteps object" do
          Connection.should_receive(:new).with(:config)
          WireLanguage.new(nil).load_code_file('foo.wire')
        end
      end

      describe "#step_matches" do
        def stub_remote_steps!(config, attributes)
          Connection.should_receive(:new).
            with(config).
            and_return( mock('remote_steps', attributes) )
        end
        
        before(:each) do
          stub_wire_file! 'one.wire', :config_one
          stub_wire_file! 'two.wire', :config_two
        end

        it "should return the matches from each of the RemoteSteps" do
          stub_remote_steps! :config_one, :step_matches => [:a, :b]
          stub_remote_steps! :config_two, :step_matches => [:c]

          wire_language = WireLanguage.new(nil)
          wire_language.load_code_file('one.wire')
          wire_language.load_code_file('two.wire')

          wire_language.step_matches('','').should == [:a, :b, :c]
        end
      end
    end
  end
end
