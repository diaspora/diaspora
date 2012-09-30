require 'spec_helper'

describe Configuration::Provider::Base do
  subject { described_class.new }
  describe "#lookup" do
    it "calls #lookup_path with the setting as array" do
      subject.should_receive(:lookup_path).with(["foo", "bar"]).and_return("something")
      subject.lookup("foo.bar").should == "something"
    end
    
    it "raises SettingNotFoundError if the #lookup_path returns nil" do
      subject.should_receive(:lookup_path).and_return(nil)
      expect {
        subject.lookup("bla")
      }.to raise_error Configuration::SettingNotFoundError
    end
  end
end
