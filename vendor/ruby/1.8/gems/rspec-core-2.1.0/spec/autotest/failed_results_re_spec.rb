require "spec_helper"

describe "failed_results_re for autotest" do
  let(:output) { StringIO.new }
  let(:formatter) { RSpec::Core::Formatters::BaseTextFormatter.new(output) }
  let(:example_output) do
    group = RSpec::Core::ExampleGroup.describe("group name")
    group.example("example name") { "this".should eq("that") }
    group.run(formatter)
    RSpec.configuration.stub(:color_enabled?) { false }
    formatter.dump_failures
    output.string
  end

  it "matches a failure" do
    re = Autotest::Rspec2.new.failed_results_re
    example_output.should =~ re
    example_output[re, 2].should == __FILE__.sub(File.expand_path('.'),'.')
  end
end
