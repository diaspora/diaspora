require "spec_helper"

module RSpec::Core
  describe Hooks do
    class HooksHost
      include Hooks
    end

    [:before, :after, :around].each do |type|
      [:each, :all].each do |scope|
        next if type == :around && scope == :all

        describe "##{type}(#{scope})" do
          it_behaves_like "metadata hash builder" do
            define_method :metadata_hash do |*args|
              instance = HooksHost.new
              args.unshift scope if scope
              hooks = instance.send(type, *args) { }
              hooks.first.options
            end
          end
        end
      end

      [true, false].each do |config_value|
        context "when RSpec.configuration.treat_symbols_as_metadata_keys_with_true_values is set to #{config_value}" do
          before(:each) do
            Kernel.stub(:warn)
            RSpec.configure { |c| c.treat_symbols_as_metadata_keys_with_true_values = config_value }
          end

          describe "##{type}(no scope)" do
            let(:instance) { HooksHost.new }

            it "defaults to :each scope if no arguments are given" do
              hooks = instance.send(type) { }
              hook = hooks.first
              instance.hooks[type][:each].should include(hook)
            end

            it "defaults to :each scope if the only argument is a metadata hash" do
              hooks = instance.send(type, :foo => :bar) { }
              hook = hooks.first
              instance.hooks[type][:each].should include(hook)
            end

            it "raises an error if only metadata symbols are given as arguments" do
              expect { instance.send(type, :foo, :bar) { } }.to raise_error(ArgumentError)
            end
          end
        end
      end
    end

    [:before, :after].each do |type|
      [:each, :all, :suite].each do |scope|
        [true, false].each do |config_value|
          context "when RSpec.configuration.treat_symbols_as_metadata_keys_with_true_values is set to #{config_value}" do
            before(:each) do
              RSpec.configure { |c| c.treat_symbols_as_metadata_keys_with_true_values = config_value }
            end

            describe "##{type}(#{scope.inspect})" do
              let(:instance) { HooksHost.new }
              let!(:hook) do
                hooks = instance.send(type, scope) { }
                hooks.first
              end

              it "does not make #{scope.inspect} a metadata key" do
                hook.options.should be_empty
              end

              it "is scoped to #{scope.inspect}" do
                instance.hooks[type][scope].should include(hook)
              end
            end
          end
        end
      end
    end

    describe "#around" do
      context "when not running the example within the around block" do
        it "does not run the example" do
          examples = []
          group = ExampleGroup.describe do
            around do |example|
            end
            it "foo" do
              examples << self
            end
          end
          group.run
          examples.should have(0).example
        end
      end

      context "when running the example within the around block" do
        it "runs the example" do
          examples = []
          group = ExampleGroup.describe do
            around do |example|
              example.run
            end
            it "foo" do
              examples << self
            end
          end
          group.run
          examples.should have(1).example
        end
      end

      context "when running the example within a block passed to a method" do
        it "runs the example" do
          examples = []
          group = ExampleGroup.describe do
            def yielder
              yield
            end
            around do |example|
              yielder { example.run }
            end
            it "foo" do
              examples << self
            end
          end
          group.run
          examples.should have(1).example
        end
      end

      describe Hooks::Hook do
        it "requires a block" do
          lambda {
            Hooks::BeforeHook.new :foo => :bar
          }.should raise_error("no block given for before hook")
        end
      end
    end
  end
end
