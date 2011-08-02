require 'spec_helper'
require 'tmpdir'

module RSpec::Core

  describe Configuration do

    let(:config) { Configuration.new }

    describe "#load_spec_files" do

      it "loads files using load" do
        config.files_to_run = ["foo.bar", "blah_spec.rb"]
        config.should_receive(:load).twice
        config.load_spec_files
      end

      context "with rspec-1 loaded" do
        before do
          Object.const_set(:Spec, Module.new)
          ::Spec::const_set(:VERSION, Module.new)
          ::Spec::VERSION::const_set(:MAJOR, 1)
        end
        after  { Object.__send__(:remove_const, :Spec) }
        it "raises with a helpful message" do
          expect {
            config.load_spec_files
          }.to raise_error(/rspec-1 has been loaded/)
        end
      end
    end

    describe "#treat_symbols_as_metadata_keys_with_true_values?" do
      it 'defaults to false' do
        config.treat_symbols_as_metadata_keys_with_true_values?.should be_false
      end

      it 'can be set to true' do
        config.treat_symbols_as_metadata_keys_with_true_values = true
        config.treat_symbols_as_metadata_keys_with_true_values?.should be_true
      end
    end

    describe "#mock_framework" do
      it "defaults to :rspec" do
        config.should_receive(:require).with('rspec/core/mocking/with_rspec')
        config.mock_framework
      end
    end

    describe "#mock_framework=" do
      [:rspec, :mocha, :rr, :flexmock].each do |framework|
        context "with #{framework}" do
          it "requires the adapter for #{framework.inspect}" do
            config.should_receive(:require).with("rspec/core/mocking/with_#{framework}")
            config.mock_framework = framework
          end
        end
      end

      context "with a module" do
        it "sets the mock_framework_adapter to that module" do
          config.stub(:require)
          mod = Module.new
          config.mock_framework = mod
          config.mock_framework.should eq(mod)
        end
      end

      it "uses the null adapter when set to any unknown key" do
        config.should_receive(:require).with('rspec/core/mocking/with_absolutely_nothing')
        config.mock_framework = :crazy_new_mocking_framework_ive_not_yet_heard_of
      end
    end

    describe "#mock_with" do
      it "delegates to mock_framework=" do
        config.should_receive(:mock_framework=).with(:rspec)
        config.mock_with :rspec
      end
    end

    describe "#expectation_framework" do
      it "defaults to :rspec" do
        config.should_receive(:require).with('rspec/core/expecting/with_rspec')
        config.expectation_frameworks
      end
    end

    describe "#expectation_framework=" do
      it "delegates to expect_with=" do
        config.should_receive(:expect_with).with([:rspec])
        config.expectation_framework = :rspec
      end
    end

    describe "#expect_with" do
      [:rspec, :stdlib].each do |framework|
        context "with #{framework}" do
          it "requires the adapter for #{framework.inspect}" do
            config.should_receive(:require).with("rspec/core/expecting/with_#{framework}")
            config.expect_with framework
          end
        end
      end

      it "raises ArgumentError if framework is not supported" do
        expect do
          config.expect_with :not_supported
        end.to raise_error(ArgumentError)
      end
    end

    describe "#expecting_with_rspec?" do
      before(:each) do
        # prevent minitest assertions from being required and included,
        # as that causes problems in some of our specs.
        config.stub(:require)
      end

      it "returns false by default" do
        config.should_not be_expecting_with_rspec
      end

      it "returns true when `expect_with :rspec` has been configured" do
        config.expect_with :rspec
        config.should be_expecting_with_rspec
      end

      it "returns true when `expect_with :rspec, :stdlib` has been configured" do
        config.expect_with :rspec, :stdlib
        config.should be_expecting_with_rspec
      end

      it "returns true when `expect_with :stdlib, :rspec` has been configured" do
        config.expect_with :stdlib, :rspec
        config.should be_expecting_with_rspec
      end

      it "returns false when `expect_with :stdlib` has been configured" do
        config.expect_with :stdlib
        config.should_not be_expecting_with_rspec
      end
    end

    describe "#files_to_run" do
      it "loads files not following pattern if named explicitly" do
        file = "./spec/rspec/core/resources/a_bar.rb"
        config.files_or_directories_to_run = file
        config.files_to_run.should == [file]
      end

      context "with default pattern" do
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
    end

    %w[pattern= filename_pattern=].each do |setter|
      describe "##{setter}" do
        context "with single pattern" do
          before { config.send(setter, "**/*_foo.rb") }
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

        context "with multiple patterns" do
          it "supports comma separated values" do
            config.send(setter, "**/*_foo.rb,**/*_bar.rb")
            dir = File.expand_path(File.dirname(__FILE__) + "/resources")
            config.files_or_directories_to_run = dir
            config.files_to_run.should include("#{dir}/a_foo.rb")
            config.files_to_run.should include("#{dir}/a_bar.rb")
          end

          it "supports comma separated values with spaces" do
            config.send(setter, "**/*_foo.rb, **/*_bar.rb")
            dir = File.expand_path(File.dirname(__FILE__) + "/resources")
            config.files_or_directories_to_run = dir
            config.files_to_run.should include("#{dir}/a_foo.rb")
            config.files_to_run.should include("#{dir}/a_bar.rb")
          end
        end
      end
    end

    describe "path with line number" do
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

    describe "#include" do

      module InstanceLevelMethods
        def you_call_this_a_blt?
          "egad man, where's the mayo?!?!?"
        end
      end

      it_behaves_like "metadata hash builder" do
        def metadata_hash(*args)
          config.include(InstanceLevelMethods, *args)
          config.include_or_extend_modules.last.last
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

      it_behaves_like "metadata hash builder" do
        def metadata_hash(*args)
          config.extend(ThatThingISentYou, *args)
          config.include_or_extend_modules.last.last
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

    describe "#run_all_when_everything_filtered?" do

      it "defaults to false" do
        config.run_all_when_everything_filtered?.should be_false
      end

      it "can be queried with question method" do
        config.run_all_when_everything_filtered = true
        config.run_all_when_everything_filtered?.should be_true
      end
    end

    describe "#color_enabled=" do
      context "given true" do
        context "with non-tty output and no autotest" do
          it "does not set color_enabled" do
            config.output_stream = StringIO.new
            config.output_stream.stub(:tty?) { false }
            config.tty = false
            config.color_enabled = true
            config.color_enabled.should be_false
          end
        end

        context "with tty output" do
          it "does not set color_enabled" do
            config.output_stream = StringIO.new
            config.output_stream.stub(:tty?) { true }
            config.tty = false
            config.color_enabled = true
            config.color_enabled.should be_true
          end
        end

        context "with tty set" do
          it "does not set color_enabled" do
            config.output_stream = StringIO.new
            config.output_stream.stub(:tty?) { false }
            config.tty = true
            config.color_enabled = true
            config.color_enabled.should be_true
          end
        end

        context "on windows" do
          before do
            @original_host  = RbConfig::CONFIG['host_os']
            RbConfig::CONFIG['host_os'] = 'mingw'
            config.stub(:require)
            config.stub(:warn)
          end

          after do
            RbConfig::CONFIG['host_os'] = @original_host
          end

          context "with ANSICON available" do
            before(:all) do
              @original_ansicon = ENV['ANSICON']
              ENV['ANSICON'] = 'ANSICON'
            end

            after(:all) do
              ENV['ANSICON'] = @original_ansicon
            end
            
            it "enables colors" do
              config.output_stream = StringIO.new
              config.output_stream.stub(:tty?) { true }
              config.color_enabled = true
              config.color_enabled.should be_true
            end

            it "leaves output stream intact" do
              config.output_stream = $stdout
              config.stub(:require) do |what|
                config.output_stream = 'foo' if what =~ /Win32/
              end
              config.color_enabled = true
              config.output_stream.should eq($stdout)
            end
          end

          context "with ANSICON NOT available" do
            it "warns to install ANSICON" do
              config.stub(:require) { raise LoadError }
              config.should_receive(:warn).
                with(/You must use ANSICON/)
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

    describe '#formatter=' do
      it "delegates to add_formatter (better API for user-facing configuration)" do
        config.should_receive(:add_formatter).with('these','options')
        config.add_formatter('these','options')
      end
    end

    describe "#add_formatter" do

      it "adds to the list of formatters" do
        config.add_formatter :documentation
        config.formatters.first.should be_an_instance_of(Formatters::DocumentationFormatter)
      end

      it "finds a formatter by name (w/ Symbol)" do
        config.add_formatter :documentation
        config.formatters.first.should be_an_instance_of(Formatters::DocumentationFormatter)
      end

      it "finds a formatter by name (w/ String)" do
        config.add_formatter 'documentation'
        config.formatters.first.should be_an_instance_of(Formatters::DocumentationFormatter)
      end

      it "finds a formatter by class" do
        formatter_class = Class.new(Formatters::BaseTextFormatter)
        config.add_formatter formatter_class
        config.formatters.first.should be_an_instance_of(formatter_class)
      end

      it "finds a formatter by class name" do
        Object.const_set("CustomFormatter", Class.new(Formatters::BaseFormatter))
        config.add_formatter "CustomFormatter"
        config.formatters.first.should be_an_instance_of(CustomFormatter)
      end

      it "finds a formatter by class fully qualified name" do
        RSpec.const_set("CustomFormatter", Class.new(Formatters::BaseFormatter))
        config.add_formatter "RSpec::CustomFormatter"
        config.formatters.first.should be_an_instance_of(RSpec::CustomFormatter)
      end

      it "requires a formatter file based on its fully qualified name" do
        config.should_receive(:require).with('rspec/custom_formatter2') do
          RSpec.const_set("CustomFormatter2", Class.new(Formatters::BaseFormatter))
        end
        config.add_formatter "RSpec::CustomFormatter2"
        config.formatters.first.should be_an_instance_of(RSpec::CustomFormatter2)
      end

      it "raises NameError if class is unresolvable" do
        config.should_receive(:require).with('rspec/custom_formatter3')
        lambda { config.add_formatter "RSpec::CustomFormatter3" }.should raise_error(NameError)
      end

      it "raises ArgumentError if formatter is unknown" do
        lambda { config.add_formatter :progresss }.should raise_error(ArgumentError)
      end

      context "with a 2nd arg defining the output" do
        it "creates a file at that path and sets it as the output" do
          path = File.join(Dir.tmpdir, 'output.txt')
          config.add_formatter('doc', path)
          config.formatters.first.output.should be_a(File)
          config.formatters.first.output.path.should eq(path)
        end
      end

    end

    describe "#filter_run" do
      it_behaves_like "metadata hash builder" do
        def metadata_hash(*args)
          config.filter_run *args
          config.filter
        end
      end

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
      it_behaves_like "metadata hash builder" do
        def metadata_hash(*args)
          config.filter_run_excluding *args
          config.exclusion_filter
        end
      end

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

    describe "#line_number=" do
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
      context "given true" do
        it "clears the backtrace clean patterns" do
          config.full_backtrace = true
          config.backtrace_clean_patterns.should == []
        end
      end

      context "given false" do
        it "restores backtrace clean patterns" do
          config.full_backtrace = false
          config.backtrace_clean_patterns.should == RSpec::Core::Configuration::DEFAULT_BACKTRACE_PATTERNS
        end
      end

      it "doesn't impact other instances of config" do
        config_1 = Configuration.new
        config_2 = Configuration.new

        config_1.full_backtrace = true
        config_2.backtrace_clean_patterns.should_not be_empty
      end
    end

    describe "#debug=true" do
      before do
        if defined?(Debugger)
          @orig_debugger = Debugger
          Object.send(:remove_const, :Debugger)
        else
          @orig_debugger = nil
        end
        Object.const_set("Debugger", debugger)
      end

      after do
        Object.send(:remove_const, :Debugger)
        Object.const_set("Debugger", @orig_debugger) if @orig_debugger
      end

      let(:debugger) { double('Debugger').as_null_object }

      it "requires 'ruby-debug'" do
        config.should_receive(:require).with('ruby-debug')
        config.debug = true
      end

      it "starts the debugger" do
        config.stub(:require)
        debugger.should_receive(:start)
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
      it "extends with 'extend'" do
        mod = Module.new
        group = ExampleGroup.describe("group", :foo => :bar)

        config.extend(mod, :foo => :bar)
        config.configure_group(group)
        group.should be_a(mod)
      end

      it "extends with 'module'" do
        mod = Module.new
        group = ExampleGroup.describe("group", :foo => :bar)

        config.include(mod, :foo => :bar)
        config.configure_group(group)
        group.included_modules.should include(mod)
      end

      it "requires only one matching filter" do
        mod = Module.new
        group = ExampleGroup.describe("group", :foo => :bar)

        config.include(mod, :foo => :bar, :baz => :bam)
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

    describe "#alias_example_to" do
      it_behaves_like "metadata hash builder" do
        def metadata_hash(*args)
          config.alias_example_to :my_example, *args
          group = ExampleGroup.describe("group")
          example = group.my_example("description")
          example.metadata
        end
      end
    end

  end
end
