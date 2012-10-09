require 'spec_helper'

describe Configuration::Provider::YAML do
  let(:settings) { {"toplevel" => "bar",
                    "some" => { 
                      "nested" => { "some" => "lala", "setting" => "foo"}
                    }
                   } }
  
  describe "#initialize" do
    it "loads the file" do
      file = "foobar.yml"
      ::YAML.should_receive(:load_file).with(file).and_return({})
      described_class.new file
    end
    
    it "raises if the file is not found" do
      ::YAML.stub(:load_file).and_raise(Errno::ENOENT)
      expect {
        described_class.new "foo"
      }.to raise_error Errno::ENOENT
    end
      
    
    context "with a namespace" do
      it "looks in the file for that namespace" do
        namespace = "some"
        ::YAML.stub(:load_file).and_return(settings)
        provider = described_class.new 'bla', namespace: namespace
        provider.instance_variable_get(:@settings).should == settings[namespace]
      end
      
      it "raises if the namespace isn't found" do
        ::YAML.stub(:load_file).and_return({})
        expect {
          described_class.new 'bla', namespace: "foo"
        }.to raise_error ArgumentError
      end
    end
    
    context "with required set to false" do
      it "doesn't raise if a file isn't found" do
        ::YAML.stub(:load_file).and_raise(Errno::ENOENT)
        expect {
          described_class.new "not_me", required: false
        }.not_to raise_error Errno::ENOENT
      end
      
      it "doesn't raise if a namespace isn't found" do
        ::YAML.stub(:load_file).and_return({})
        expect {
          described_class.new 'bla', namespace: "foo", required: false
        }.not_to raise_error ArgumentError
      end
    end
  end
  
  describe "#lookup_path" do
    before do
      ::YAML.stub(:load_file).and_return(settings)
      @provider = described_class.new 'dummy'
    end
    
    it "looks up the whole nesting" do
      @provider.lookup_path(["some", "nested", "some"]).should == settings["some"]["nested"]["some"]
    end
    
    it "returns nil if no setting is found" do
      @provider.lookup_path(["not_me"]).should be_nil
    end
  end
end
