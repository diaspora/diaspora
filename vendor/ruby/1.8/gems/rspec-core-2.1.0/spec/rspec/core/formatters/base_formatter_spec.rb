require 'spec_helper'
require 'rspec/core/formatters/base_formatter'

describe RSpec::Core::Formatters::BaseFormatter do

  let(:output)    { StringIO.new }
  let(:formatter) { RSpec::Core::Formatters::BaseFormatter.new(output) }

  describe "backtrace_line" do
    it "trims current working directory" do
      formatter.__send__(:backtrace_line, File.expand_path(__FILE__)).should == "./spec/rspec/core/formatters/base_formatter_spec.rb"
    end

    it "leaves the original line intact" do
      original_line = File.expand_path(__FILE__)
      formatter.__send__(:backtrace_line, original_line)
      original_line.should eq(File.expand_path(__FILE__))
    end
  end

  describe "read_failed_line" do
    it "deals gracefully with a heterogeneous language stack trace" do
      exception = mock(:Exception, :backtrace => [
        "at Object.prototypeMethod (foo:331:18)",
        "at Array.forEach (native)",
        "at a_named_javascript_function (/some/javascript/file.js:39:5)",
        "/some/line/of/ruby.rb:14"
      ])
      example = mock(:Example, :file_path => __FILE__)
      lambda {
        formatter.send(:read_failed_line, exception, example)
      }.should_not raise_error
    end
  end

end
