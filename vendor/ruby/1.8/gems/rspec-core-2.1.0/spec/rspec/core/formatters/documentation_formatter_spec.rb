require 'spec_helper'
require 'rspec/core/formatters/documentation_formatter'

module RSpec::Core::Formatters
  describe DocumentationFormatter do
    it "numbers the failures" do

      examples = [
        double("example 1",
               :description => "first example",
               :execution_result => {:status => 'failed', :exception_encountered => Exception.new }
              ),
        double("example 2",
               :description => "second example",
               :execution_result => {:status => 'failed', :exception_encountered => Exception.new }
              )
      ]

      output = StringIO.new
      RSpec.configuration.stub(:color_enabled?) { false }

      formatter = RSpec::Core::Formatters::DocumentationFormatter.new(output)

      examples.each {|e| formatter.example_failed(e) }

      output.string.should =~ /first example \(FAILED - 1\)/m
      output.string.should =~ /second example \(FAILED - 2\)/m
    end

    it "represents nested group using hierarchy tree" do

      output = StringIO.new
      RSpec.configuration.stub(:color_enabled?) { false }

      formatter = RSpec::Core::Formatters::DocumentationFormatter.new(output)

      group = RSpec::Core::ExampleGroup.describe("root")
      context1 = group.describe("context 1")
      context1.example("nested example 1.1"){}
      context1.example("nested example 1.2"){}

      context11 = context1.describe("context 1.1")
      context11.example("nested example 1.1.1"){}
      context11.example("nested example 1.1.2"){}

      context2 = group.describe("context 2")
      context2.example("nested example 2.1"){}
      context2.example("nested example 2.2"){}

      group.run(RSpec::Core::Reporter.new(formatter))

      output.string.should eql "
root
  context 1
    nested example 1.1
    nested example 1.2
    context 1.1
      nested example 1.1.1
      nested example 1.1.2
  context 2
    nested example 2.1
    nested example 2.2
"
    end
  end
end
