require 'spec_helper'

describe Configuration::Settings do
  describe "#method_missing" do
    subject { described_class.create }
    
    it "delegates the call to a new proxy object" do
      proxy = mock
      Configuration::Proxy.should_receive(:new).and_return(proxy)
      proxy.should_receive(:method_missing).with(:some_setting).and_return("foo")
      subject.some_setting
    end
  end
  
  [:lookup, :add_provider, :[]].each do |method|
    describe "#{method}" do
      subject { described_class.create }
      
      it "delegates the call to #lookup_chain" do
        subject.lookup_chain.should_receive(method)
        subject.send(method)
      end
    end
  end
end
