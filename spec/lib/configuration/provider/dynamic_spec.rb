require 'spec_helper'

describe Configuration::Provider::Dynamic do
  subject { described_class.new }
  describe "#lookup_path" do
    it "returns nil if the setting was never set" do
      subject.lookup_path(["not_me"]).should be_nil
    end
    
    it "remembers the setting if it ends with =" do
      subject.lookup_path(["find_me", "later="], "there")
      subject.lookup_path(["find_me", "later"]).should == "there"
    end
    
    it "calls .get on the argument if a proxy object is given" do
      proxy = mock
      proxy.stub(:respond_to?).and_return(true)
      proxy.stub(:_proxy?).and_return(true)
      proxy.should_receive(:get)
      subject.lookup_path(["bla="], proxy)
    end
  end
end
