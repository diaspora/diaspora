require 'spec_helper'

module RSpec::Core

  describe Configuration do

    let(:config) { subject }

    describe "#load_spec_files" do
      it "loads files using load" do
        config.files_to_run = ["foo.bar", "blah_spec.rb"]
        config.should_receive(:load).twice
        config.load_spec_files
      end
    end

    describe "mock_framework" do
      before(:each) do
        config.stub(:require)
      end

      it "defaults to :rspec" do
        config.should_receive(:require).with('rspec/core/mocking/with_rspec')
        config.require_mock_framework_adapter
      end

      [:rspec, :mocha, :rr, :flexmock].each do |framework|
        it "uses #{framework.inspect} framework when set explicitly" do
          config.should_receive(:require).with("rspec/core/mocking/with_#{framework}")
          config.mock_framework = framework
          config.require_mock_framework_adapter
        end
      end

      it "uses the null adapter when set to any unknown key" do
        config.should_receive(:require).with('rspec/core/mocking/with_absolutely_nothing')
        config.mock_framework = :crazy_new_mocking_framework_ive_not_yet_heard_of
        config.require_mock_framework_adapter
      end

      it "supports mock_with for backward compatibility with rspec-1.x" do
        config.should_receive(:require).with('rspec/core/mocking/with_rspec')
        config.mock_with :rspec
        config.require_mock_framework_adapter
      end

    end

    describe "expectation_framework" do

      it "defaults to :rspec" do
        config.should_receive(:require).with('rspec/core/expecting/with_rspec')
        config.require_expectation_framework_adapter
      end

      [:rspec].each do |framework|
        it "uses #{framework.inspect} framework when set explicitly" do
          config.should_receive(:require).with("rspec/core/expecting/with_#{framework}")
          config.mock_framework = framework
          config.require_expectation_framework_adapter
        end
      end

      it "supports expect_with for backward compatibility with rspec-1.x" do
        config.should_receive(:require).with('rspec/core/expecting/with_rspec')
        config.mock_with :rspec
        config.require_expectation_framework_adapter
      end

      it "raises ArgumentError if framework is not supported" do
        config.expectation_framework = :not_supported
        expect { config.require_expectation_framework_adapter }.to raise_error(ArgumentError)
      end

    end

    context "setting the files to run" do

      it "loads files not following pattern if named explicitly" do
        file = "./spec/rspec/core/resources/a_bar.rb"
        config.files_or_directories_to_run = file
        config.files_to_run.should == [file]
      end

      describe "with default --pattern" do

        it "loads files named _spec.rb" do
          dir = "./spec/rspec/core/resources"
          config.files_or_directories_to_run = dir
          config.files_to_run.should == ["#{dir}/a_spec.rb"]
        end

        it "loads files in Windows" do
          file = "C:\\path\\to\\project\\spec\\sub\\foo_spec.rb"
          config.files_or_directories_to_run = file
          config.files_to_run.should == [file]
        end

      end

      describe "with explicit pattern (single)" do

        before do
          config.filename_pattern = "**/*_foo.rb"
        end

        it "loads files following pattern" do
          file = File.expand_path(File.dirname(__FILE__) + "/resources/a_foo.rb")
          config.files_or_directories_to_run = file
          config.files_to_run.should include(file)
        end

        it "loads files in directories following pattern" do
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          config.files_or_directories_to_run = dir
          config.files_to_run.should include("#{dir}/a_foo.rb")
        end

        it "does not load files in directories not following pattern" do
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          config.files_or_directories_to_run = dir
          config.files_to_run.should_not include("#{dir}/a_bar.rb")
        end

      end

      context "with explicit pattern (comma,separated,values)" do

        before do
          config.filename_pattern = "**/*_foo.rb,**/*_bar.rb"
        end

        it "supports comma separated values" do
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          config.files_or_directories_to_run = dir
          config.files_to_run.should include("#{dir}/a_foo.rb")
          config.files_to_run.should include("#{dir}/a_bar.rb")
        end

        it "supports comma separated values with spaces" do
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          config.files_or_directories_to_run = dir
          config.files_to_run.should include("#{dir}/a_foo.rb")
          config.files_to_run.should include("#{dir}/a_bar.rb")
        end

      end

      context "with line number" do

        it "assigns the line number as the filter" do
          config.files_or_directories_to_run = "path/to/a_spec.rb:37"
          config.filter.should == {:line_number => 37}
        end

      end

      context "with full_description" do
        it "overrides :focused" do
          config.filter_run :focused => true
          config.full_description = "foo"
          config.filter.should_not have_key(:focused)
        end

        it "assigns the example name as the filter on description" do
          config.full_description = "foo"
          config.filter.should == {:full_description => /foo/}
        end

      end

    end

    describe "#include" do

      module InstanceLevelMethods
        def you_call_this_a_blt?
          "egad man, where's the mayo?!?!?"
        end
      end

      context "with no filter" do
        it "includes the given module into each example group" do
          RSpec.configure do |c|
            c.include(InstanceLevelMethods)
          end

          group = ExampleGroup.describe('does like, stuff and junk', :magic_key => :include) { }
          group.should_not respond_to(:you_call_this_a_blt?)
          group.new.you_call_this_a_blt?.should == "egad man, where's the mayo?!?!?"
        end
      end

      context "with a filter" do
        it "includes the given module into each matching example group" do
          RSpec.configure do |c|
            c.include(InstanceLevelMethods, :magic_key => :include)
          end

          group = ExampleGroup.describe('does like, stuff and junk', :magic_key => :include) { }
          group.should_not respond_to(:you_call_this_a_blt?)
          group.new.you_call_this_a_blt?.should == "egad man, where's the mayo?!?!?"
        end
      end

    end

    describe "#extend" do

      module ThatThingISentYou
        def that_thing
        end
      end

      it "extends the given module into each matching example group" do
        RSpec.configure do |c|
          c.extend(ThatThingISentYou, :magic_key => :extend)
        end

        group = ExampleGroup.describe(ThatThingISentYou, :magic_key => :extend) { }
        group.should respond_to(:that_thing)
      end

    end

    describe "run_all_when_everything_filtered?" do

      it "defaults to false" do
        config.run_all_when_everything_filtered?.should == false
      end

      it "can be queried with question method" do
        config.run_all_when_everything_filtered = true
        config.run_all_when_everything_filtered?.should == true
      end
    end

    describe "#color_enabled=" do
      context "given true" do
        context "with non-tty output and no autotest" do
          it "does not set color_enabled" do
            config.output_stream = StringIO.new
            config.output_stream.stub(:tty?) { false }
            config.autotest = false
            config.color_enabled = true
            config.color_enabled.should be_false
          end
        end

        context "with tty output" do
          it "does not set color_enabled" do
            config.output_stream = StringIO.new
            config.output_stream.stub(:tty?) { true }
            config.autotest = false
            config.color_enabled = true
            config.color_enabled.should be_true
          end
        end

        context "with autotest output" do
          it "does not set color_enabled" do
            config.output_stream = StringIO.new
            config.output_stream.stub(:tty?) { false }
            config.autotest = true
            config.color_enabled = true
            config.color_enabled.should be_true
          end
        end

        context "on windows" do
          before do
            @original_host  = RbConfig::CONFIG['host_os']
            @original_stdout = $stdout
            @original_stderr = $stderr
            RbConfig::CONFIG['host_os'] = 'mswin'
            config.stub(:require)
            config.stub(:warn)
          end

          after do
            RbConfig::CONFIG['host_os'] = @original_host
            $stdout = @original_stdout
            $stderr = @original_stderr
          end

          context "with win32console available" do
            it "requires win32console" do
              config.should_receive(:require).
                with("Win32/Console/ANSI")
              config.color_enabled = true
            end

            context "with $stdout/err assigned to config.output/error_stream" do
              it "reassigns new $stdout to output_stream" do
                config.output_stream = $stdout
                substitute_stdout = StringIO.new
                config.stub(:require) do |what|
                  $stdout = substitute_stdout if what =~ /Win32/
                end
                config.color_enabled = true
                config.output_stream.should eq(substitute_stdout)
              end

              it "reassigns new $stderr to error_stream" do
                config.error_stream = $stderr
                substitute_stderr = StringIO.new
                config.stub(:require) do |what|
                  $stderr = substitute_stderr if what =~ /Win32/
                end
                config.color_enabled = true
                config.error_stream.should eq(substitute_stderr)
              end
            end

            context "without $stdout/err assigned to config.output/error_stream" do
              it "leaves output stream intact" do
                config.output_stream = output_stream = StringIO.new
                config.stub(:require) do |what|
                  $stdout = StringIO.new if what =~ /Win32/
                end
                config.color_enabled = true
                config.output_stream.should eq(output_stream)
              end

              it "leaves error stream intact" do
                config.error_stream = error_stream = StringIO.new
                config.stub(:require) do |what|
                  $stderr = StringIO.new if what =~ /Win32/
                end
                config.color_enabled = true
                config.error_stream.should eq(error_stream)
              end
            end

          end

          context "with win32console NOT available" do
            it "warns to install win32console" do
              config.stub(:require) { raise LoadError }
              config.should_receive(:warn).
                with(/You must 'gem install win32console'/)
              config.color_enabled = true
            end

            it "sets color_enabled to false" do
              config.stub(:require) { raise LoadError }
              config.color_enabled = true
              config.color_enabled.should be_false
            end
          end
        end
      end
    end

    describe 'formatter=' do

      it "sets formatter_to_use based on name" do
        config.formatter = :documentation
        config.formatter.should be_an_instance_of(Formatters::DocumentationFormatter)
        config.formatter = 'documentation'
        config.formatter.should be_an_instance_of(Formatters::DocumentationFormatter)
      end

      it "sets a formatter based on its class" do
        formatter_class = Class.new(Formatters::BaseTextFormatter)
        config.formatter = formatter_class
        config.formatter.should be_an_instance_of(formatter_class)
      end

      it "sets a formatter based on its class name" do
        Object.const_set("CustomFormatter", Class.new(Formatters::BaseFormatter))
        config.formatter = "CustomFormatter"
        config.formatter.should be_an_instance_of(CustomFormatter)
      end

      it "sets a formatter based on its class fully qualified name" do
        RSpec.const_set("CustomFormatter", Class.new(Formatters::BaseFormatter))
        config.formatter = "RSpec::CustomFormatter"
        config.formatter.should be_an_instance_of(RSpec::CustomFormatter)
      end

      it "requires and sets a formatter based on its class fully qualified name" do
        config.should_receive(:require).with('rspec/custom_formatter2') do
          RSpec.const_set("CustomFormatter2", Class.new(Formatters::BaseFormatter))
        end
        config.formatter = "RSpec::CustomFormatter2"
        config.formatter.should be_an_instance_of(RSpec::CustomFormatter2)
      end

      it "raises NameError if class is unresolvable" do
        config.should_receive(:require).with('rspec/custom_formatter3')
        lambda { config.formatter = "RSpec::CustomFormatter3" }.should raise_error(NameError)
      end

      it "raises ArgumentError if formatter is unknown" do
        lambda { config.formatter = :progresss }.should raise_error(ArgumentError)
      end

    end

    describe "#filter_run" do
      it "sets the filter" do
        config.filter_run :focus => true
        config.filter[:focus].should == true
      end

      it "merges with existing filters" do
        config.filter_run :filter1 => true
        config.filter_run :filter2 => false

        config.filter[:filter1].should == true
        config.filter[:filter2].should == false
      end

      it "warns if :line_number is already a filter" do
        config.filter_run :line_number => 100
        config.should_receive(:warn).with(
          "Filtering by {:focus=>true} is not possible since you " \
          "are already filtering by {:line_number=>100}"
        )
        config.filter_run :focus => true
      end

      it "warns if :full_description is already a filter" do
        config.filter_run :full_description => 'foo'
        config.should_receive(:warn).with(
          "Filtering by {:focus=>true} is not possible since you " \
          "are already filtering by {:full_description=>\"foo\"}"
        )
        config.filter_run :focus => true
      end
    end

    describe "#filter_run_excluding" do
      it "sets the filter" do
        config.filter_run_excluding :slow => true
        config.exclusion_filter[:slow].should == true
      end

      it "merges with existing filters" do
        config.filter_run_excluding :filter1 => true
        config.filter_run_excluding :filter2 => false

        config.exclusion_filter[:filter1].should == true
        config.exclusion_filter[:filter2].should == false
      end
    end

    describe "#exclusion_filter" do
      describe "the default :if filter" do
        it "does not exclude a spec with no :if metadata" do
          config.exclusion_filter[:if].call(nil, {}).should be_false
        end

        it "does not exclude a spec with { :if => true } metadata" do
          config.exclusion_filter[:if].call(true, {:if => true}).should be_false
        end

        it "excludes a spec with { :if => false } metadata" do
          config.exclusion_filter[:if].call(false, {:if => false}).should be_true
        end

        it "excludes a spec with { :if => nil } metadata" do
          config.exclusion_filter[:if].call(false, {:if => nil}).should be_true
        end
      end

      describe "the default :unless filter" do
        it "excludes a spec with  { :unless => true } metadata" do
          config.exclusion_filter[:unless].call(true).should be_true
        end

        it "does not exclude a spec with { :unless => false } metadata" do
          config.exclusion_filter[:unless].call(false).should be_false
        end

        it "does not exclude a spec with { :unless => nil } metadata" do
          config.exclusion_filter[:unless].call(nil).should be_false
        end
      end
    end

    describe "line_number=" do
      before { config.stub(:warn) }

      it "sets the line number" do
        config.line_number = '37'
        config.filter.should == {:line_number => 37}
      end

      it "overrides :focused" do
        config.filter_run :focused => true
        config.line_number = '37'
        config.filter.should == {:line_number => 37}
      end

      it "prevents :focused" do
        config.line_number = '37'
        config.filter_run :focused => true
        config.filter.should == {:line_number => 37}
      end
    end

    describe "#full_backtrace=" do
      it "clears the backtrace clean patterns" do
        config.full_backtrace = true
        config.backtrace_clean_patterns.should == []
      end

      it "doesn't impact other instances of config" do
        config_1 = Configuration.new
        config_2 = Configuration.new

        config_1.full_backtrace = true
        config_2.backtrace_clean_patterns.should_not be_empty
      end
    end

    describe "#debug=true" do
      it "requires 'ruby-debug'" do
        config.should_receive(:require).with('ruby-debug')
        config.debug = true
      end
    end

    describe "#debug=false" do
      it "does not require 'ruby-debug'" do
        config.should_not_receive(:require).with('ruby-debug')
        config.debug = false
      end
    end

    describe "#output=" do
      it "sets the output" do
        output = mock("output")
        config.output = output
        config.output.should equal(output)
      end
    end

    describe "#libs=" do
      it "adds directories to the LOAD_PATH" do
        $LOAD_PATH.should_receive(:unshift).with("a/dir")
        config.libs = ["a/dir"]
      end
    end

    describe "#requires=" do
      it "requires paths" do
        config.should_receive(:require).with("a/path")
        config.requires = ["a/path"]
      end
    end

    describe "#add_setting" do
      describe "with no modifiers" do
        context "with no additional options" do
          before { config.add_setting :custom_option }

          it "defaults to nil" do
            config.custom_option.should be_nil
          end

          it "adds a predicate" do
            config.custom_option?.should be_false
          end

          it "can be overridden" do
            config.custom_option = "a value"
            config.custom_option.should eq("a value")
          end
        end

        context "with :default => 'a value'" do
          before { config.add_setting :custom_option, :default => 'a value' }

          it "defaults to 'a value'" do
            config.custom_option.should eq("a value")
          end

          it "returns true for the predicate" do
            config.custom_option?.should be_true
          end

          it "can be overridden with a truthy value" do
            config.custom_option = "a new value"
            config.custom_option.should eq("a new value")
          end

          it "can be overridden with nil" do
            config.custom_option = nil
            config.custom_option.should eq(nil)
          end

          it "can be overridden with false" do
            config.custom_option = false
            config.custom_option.should eq(false)
          end
        end
      end

      context "with :alias => " do
        before do
          config.add_setting :custom_option
          config.add_setting :another_custom_option, :alias => :custom_option
        end

        it "delegates the getter to the other option" do
          config.another_custom_option = "this value"
          config.custom_option.should == "this value"
        end

        it "delegates the setter to the other option" do
          config.custom_option = "this value"
          config.another_custom_option.should == "this value"
        end

        it "delegates the predicate to the other option" do
          config.custom_option = true
          config.another_custom_option?.should be_true
        end
      end
    end

    describe "#configure_group" do
      it "extends with modules" do
        mod = Module.new
        group = ExampleGroup.describe("group", :foo => :bar)

        config.extend(mod, :foo => :bar)
        config.configure_group(group)
        group.should be_a(mod)
      end

      it "includes modules" do
        mod = Module.new
        group = ExampleGroup.describe("group", :foo => :bar)

        config.include(mod, :foo => :bar)
        config.configure_group(group)
        group.included_modules.should include(mod)
      end

      it "includes each one before deciding whether to include the next" do
        mod1 = Module.new do
          def self.included(host)
            host.metadata[:foo] = :bar
          end
        end
        mod2 = Module.new

        group = ExampleGroup.describe("group")

        config.include(mod1)
        config.include(mod2, :foo => :bar)
        config.configure_group(group)
        group.included_modules.should include(mod1)
        group.included_modules.should include(mod2)
      end
    end
  end
end
