require 'spec_helper'

describe Configuration::Proxy do
  let(:lookup_chain) { mock }
  before do
    lookup_chain.stub(:lookup).and_return("something")
  end
  
  describe "#method_missing" do
    it "calls #get if the method ends with a ?" do
      lookup_chain.should_receive(:lookup).with("enable").and_return(false)
      described_class.new(lookup_chain).method_missing(:enable?)
    end
    
    it "calls #get if the method ends with a =" do
      lookup_chain.should_receive(:lookup).with("url=").and_return(false)
      described_class.new(lookup_chain).method_missing(:url=)
    end
  end
  
  describe "#get" do
    [:to_str, :to_s, :to_xml, :respond_to?, :present?, :!=,
     :each, :try, :size, :length, :count, :==, :=~, :gsub, :blank?, :chop,
     :start_with?, :end_with?].each do |method|
      it "is called for accessing #{method} on the proxy" do
        target = mock
        lookup_chain.should_receive(:lookup).and_return(target)
        target.should_receive(method).and_return("something")
        described_class.new(lookup_chain).something.__send__(method, mock)
      end
    end
    
    described_class::COMMON_KEY_NAMES.each do |method|
      it "is not called for accessing #{method} on the proxy" do
        target = mock
        lookup_chain.should_not_receive(:lookup).and_return(target)
        target.should_not_receive(method).and_return("something")
        described_class.new(lookup_chain).something.__send__(method, mock)
      end
    end
    
    it "strips leading dots" do
      lookup_chain.should_receive(:lookup).with("foo.bar").and_return("something")
      described_class.new(lookup_chain).foo.bar.get
    end
    
    it "returns nil if no setting is given" do
      described_class.new(lookup_chain).get.should be_nil
    end
    
    it "strips ? at the end" do
      lookup_chain.should_receive(:lookup).with("foo.bar").and_return("something")
      described_class.new(lookup_chain).foo.bar?
    end
  end
end
