require "spec_helper"

describe "autotest/discover.rb" do
  context "with /.rspec present" do
    it "adds 'rspec2' to the list of discoveries" do
      File.stub(:exist?).with("./.rspec") { true }
      Autotest.should_receive(:add_discovery)
      load File.expand_path("../../../lib/autotest/discover.rb", __FILE__)
    end
  end

  context "with /.rspec absent" do
    it "does not add 'rspec2' to the list of discoveries" do
      File.stub(:exist?) { false }
      Autotest.should_not_receive(:add_discovery)
      load File.expand_path("../../../lib/autotest/discover.rb", __FILE__)
    end
  end
end
