require 'spec_helper'

class InvalidConfigurationProvider; end
class ValidConfigurationProvider
  def lookup(setting, *args); end
end

describe Configuration::LookupChain do
  subject { described_class.new }
  
  describe "#add_provider" do
    it "adds a valid provider" do
      expect {
        subject.add_provider ValidConfigurationProvider
      }.to change { subject.instance_variable_get(:@provider).size }.by 1
    end
    
    it "doesn't add an invalid provider" do
      expect {
        subject.add_provider InvalidConfigurationProvider
      }.to raise_error ArgumentError
    end
    
    it "passes extra args to the provider" do
      ValidConfigurationProvider.should_receive(:new).with(:extra)
      subject.add_provider ValidConfigurationProvider, :extra
    end
  end
  
  describe "#lookup" do
    before(:all) do
      subject.add_provider ValidConfigurationProvider
      subject.add_provider ValidConfigurationProvider
      @provider = subject.instance_variable_get(:@provider)
    end
    
    it "it tries all providers" do
      setting = "some.setting"
      @provider.each do |provider|
        provider.should_receive(:lookup).with(setting).and_raise(Configuration::SettingNotFoundError)
      end
      
      subject.lookup(setting)
    end
    
    it "stops if a value is found" do
      @provider[0].should_receive(:lookup).and_return("something")
      @provider[1].should_not_receive(:lookup)
      subject.lookup("bla")
    end
    
    it "converts numbers to strings" do
      @provider[0].stub(:lookup).and_return(5)
      subject.lookup("foo").should == "5"
    end
    
    it "does not convert false to a string" do
      @provider[0].stub(:lookup).and_return(false)
      subject.lookup("enable").should be_false
    end
    
    it "returns nil if no value is found" do
      @provider.each { |p| p.stub(:lookup).and_raise(Configuration::SettingNotFoundError) }
      subject.lookup("not.me").should be_nil
    end
  end
end
