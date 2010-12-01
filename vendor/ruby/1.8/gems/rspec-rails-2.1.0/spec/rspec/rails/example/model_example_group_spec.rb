require "spec_helper"

module RSpec::Rails
  describe ModelExampleGroup do
    it { should be_included_in_files_in('./spec/models/') }
    it { should be_included_in_files_in('.\\spec\\models\\') }

    it "adds :type => :model to the metadata" do
      group = RSpec::Core::ExampleGroup.describe do
        include ModelExampleGroup
      end
      group.metadata[:type].should eq(:model)
    end
  end
end
