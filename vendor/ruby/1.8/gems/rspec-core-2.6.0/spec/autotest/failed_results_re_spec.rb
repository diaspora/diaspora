require "spec_helper"

describe "failed_results_re for autotest" do
  let(:output) { StringIO.new }
  let(:formatter) { RSpec::Core::Formatters::BaseTextFormatter.new(output) }
  let(:example_output) do
    group = RSpec::Core::ExampleGroup.describe("group name")
    group.example("example name") { "this".should eq("that") }
    group.run(formatter)
    formatter.dump_failures
    output.string
  end

  context "output does not have color enabled" do
    before do
      RSpec.configuration.stub(:color_enabled?) { false }
    end

    it "matches a failure" do
      re = Autotest::Rspec2.new.failed_results_re
      example_output.should =~ re
      example_output.should include(__FILE__.sub(File.expand_path('.'),'.'))
    end
  end

  context "output has color enabled" do
    before do
      RSpec.configuration.stub(:color_enabled?) { true }
    end

    it "matches a failure" do
      re = Autotest::Rspec2.new.failed_results_re
      example_output.should =~ re
      example_output.should include(__FILE__.sub(File.expand_path('.'),'.'))
    end
  end
end
