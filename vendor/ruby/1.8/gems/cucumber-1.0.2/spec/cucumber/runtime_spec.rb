require 'spec_helper'

module Cucumber
describe Runtime do
  subject { Runtime.new(options) }
  let(:options)     { {} }
  
  describe "#features_paths" do
    let(:options) { {:paths => ['foo/bar/baz.feature', 'foo/bar/features/baz.feature', 'other_features'] } }
    it "returns the value from configuration.paths" do
      subject.features_paths.should == options[:paths]
    end
  end
  
  describe "#configure" do
    let(:support_code)      { double(Runtime::SupportCode).as_null_object }
    let(:results)           { double(Runtime::Results).as_null_object     }
    let(:new_configuration) { double('New configuration')}
    before(:each) do
      Runtime::SupportCode.stub(:new => support_code)
      Runtime::Results.stub(:new => results)
    end
    
    it "tells the support_code and results about the new configuration" do
      support_code.should_receive(:configure).with(new_configuration)
      results.should_receive(:configure).with(new_configuration)
      subject.configure(new_configuration)
    end
    
    it "replaces the existing configuration" do
      # not really sure how to test this. Maybe we should just expose 
      # Runtime#configuration with an attr_reader?
      some_new_paths = ['foo/bar', 'baz']
      new_configuration.stub(:paths => some_new_paths)
      subject.configure(new_configuration)
      subject.features_paths.should == some_new_paths
    end
  end
  
end
end