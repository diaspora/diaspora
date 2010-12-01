require 'spec_helper'

module Cucumber
  describe Configuration do
    describe ".default" do
      subject { Configuration.default }
      
      it "has an autoload_code_paths containing the standard support and step_definitions folders" do
        subject.autoload_code_paths.should include('features/support')
        subject.autoload_code_paths.should include('features/step_definitions')
      end
    end
    
    describe "with custom user options" do
      let(:user_options) { { :autoload_code_paths => ['foo/bar/baz'] } }
      subject { Configuration.new(user_options) }
      
      it "allows you to override the defaults" do
        subject.autoload_code_paths.should == ['foo/bar/baz']
      end
    end
  end
end