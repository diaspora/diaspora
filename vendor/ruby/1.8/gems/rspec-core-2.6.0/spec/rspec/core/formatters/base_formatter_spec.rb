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

    context "when String alias to_int to_i" do
      before do
        String.class_eval do
          alias :to_int :to_i
        end
      end

      after do
        String.class_eval do
          undef to_int
        end
      end

      it "doesn't hang when file exists" do
        pending("This issue still exists on JRuby, but should be resolved shortly: https://github.com/rspec/rspec-core/issues/295", :if => RUBY_PLATFORM == 'java')
        exception = mock(:Exception, :backtrace => [ "#{__FILE__}:#{__LINE__}"])

        example = mock(:Example, :file_path => __FILE__)
        formatter.send(:read_failed_line, exception, example).should
          eql %Q{        exception = mock(:Exception, :backtrace => [ "\#{__FILE__}:\#{__LINE__}"])\n}
      end

    end
  end

  describe "#format_backtrace" do
    let(:rspec_expectations_dir) { "/path/to/rspec-expectations/lib" }
    let(:rspec_core_dir) { "/path/to/rspec-core/lib" }
    let(:backtrace) do
      [
        "#{rspec_expectations_dir}/rspec/matchers/operator_matcher.rb:51:in `eval_match'",
        "#{rspec_expectations_dir}/rspec/matchers/operator_matcher.rb:29:in `=='",
        "./my_spec.rb:5",
        "#{rspec_core_dir}/rspec/core/example.rb:52:in `run'",
        "#{rspec_core_dir}/rspec/core/runner.rb:37:in `run'",
        RSpec::Core::Runner::AT_EXIT_HOOK_BACKTRACE_LINE,
        "./my_spec.rb:3"
      ]
    end

    it "removes lines from rspec and lines that come before the invocation of the at_exit autorun hook" do
      formatter.format_backtrace(backtrace, stub.as_null_object).should == ["./my_spec.rb:5"]
    end
  end

end
