require 'spec_helper'

describe Configuration::Provider::Env do
  subject { described_class.new }
  let(:existing_path) { ['existing', 'setting']}
  let(:not_existing_path) { ['not', 'existing', 'path']}
  let(:array_path) { ['array'] }
  before(:all) do
    ENV['EXISTING_SETTING'] = "there"
    ENV['ARRAY'] = "foo,bar,baz"
  end
  
  after(:all) do
    ENV['EXISTING_SETTING'] = nil
    ENV['ARRAY'] = nil
  end
  
  describe '#lookup_path' do
    it "joins and upcases the path" do
      ENV.should_receive(:[]).with("EXISTING_SETTING")
      subject.lookup_path(existing_path)
    end
    
    it "returns nil if the setting isn't available" do
      subject.lookup_path(not_existing_path).should be_nil
    end
    
    it "makes an array out of comma separated values" do
      subject.lookup_path(array_path).should == ["foo", "bar", "baz"]
    end
  end
end
