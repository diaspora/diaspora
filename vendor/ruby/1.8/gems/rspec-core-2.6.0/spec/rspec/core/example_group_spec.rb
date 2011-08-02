require 'spec_helper'

class SelfObserver
  def self.cache
    @cache ||= []
  end

  def initialize
    self.class.cache << self
  end
end

module RSpec::Core

  describe ExampleGroup do
    it_behaves_like "metadata hash builder" do
      def metadata_hash(*args)
        group = ExampleGroup.describe('example description', *args)
        group.metadata
      end
    end

    context 'when RSpec.configuration.treat_symbols_as_metadata_keys_with_true_values is set to false' do
      before(:each) do
        RSpec.configure { |c| c.treat_symbols_as_metadata_keys_with_true_values = false }
        Kernel.stub(:warn)
      end

      it 'processes string args as part of the description' do
        group = ExampleGroup.describe("some", "separate", "strings")
        group.description.should == "some separate strings"
      end

      it 'processes symbol args as part of the description' do
        group = ExampleGroup.describe(:some, :separate, :symbols)
        group.description.should == "some separate symbols"
      end
    end

    context 'when RSpec.configuration.treat_symbols_as_metadata_keys_with_true_values is set to true' do
      let(:group) { ExampleGroup.describe(:symbol) }
      before(:each) do
        RSpec.configure { |c| c.treat_symbols_as_metadata_keys_with_true_values = true }
      end

      it 'does not treat the first argument as a metadata key even if it is a symbol' do
        group.metadata.should_not include(:symbol)
      end

      it 'treats the first argument as part of the description when it is a symbol' do
        group.description.should == "symbol"
      end
    end

    describe "top level group" do
      it "runs its children" do
        examples_run = []
        group = ExampleGroup.describe("parent") do
          describe("child") do
            it "does something" do
              examples_run << example
            end
          end
        end

        group.run
        examples_run.should have(1).example
      end

      context "with a failure in the top level group" do
        it "runs its children " do
          examples_run = []
          group = ExampleGroup.describe("parent") do
            it "fails" do
              examples_run << example
              raise "fail"
            end
            describe("child") do
              it "does something" do
                examples_run << example
              end
            end
          end

          group.run
          examples_run.should have(2).examples
        end
      end

      describe "descendants" do
        it "returns self + all descendants" do
          group = ExampleGroup.describe("parent") do
            describe("child") do
              describe("grandchild 1") {}
              describe("grandchild 2") {}
            end
          end
          group.descendants.size.should == 4
        end
      end
    end

    describe "child" do
      it "is known by parent" do
        parent = ExampleGroup.describe
        child = parent.describe
        parent.children.should == [child]
      end

      it "is not registered in world" do
        world = RSpec::Core::World.new
        parent = ExampleGroup.describe
        world.register(parent)
        child = parent.describe
        world.example_groups.should == [parent]
      end
    end

    describe "filtering" do
      let(:world) { World.new }

      shared_examples "matching filters" do
        context "inclusion" do
          before { world.stub(:inclusion_filter).and_return(filter_metadata) }

          it "includes examples in groups matching filter" do
            group = ExampleGroup.describe("does something", spec_metadata)
            group.stub(:world) { world }
            all_examples = [ group.example("first"), group.example("second") ]

            group.filtered_examples.should == all_examples
          end

          it "includes examples directly matching filter" do
            group = ExampleGroup.describe("does something")
            group.stub(:world) { world }
            filtered_examples = [
              group.example("first", spec_metadata),
              group.example("second", spec_metadata)
            ]
            group.example("third (not-filtered)")

            group.filtered_examples.should == filtered_examples
          end
        end

        context "exclusion" do
          before { world.stub(:exclusion_filter).and_return(filter_metadata) }
          it "excludes examples in groups matching filter" do
            group = ExampleGroup.describe("does something", spec_metadata)
            group.stub(:world) { world }
            all_examples = [ group.example("first"), group.example("second") ]

            group.filtered_examples.should be_empty
          end

          it "excludes examples directly matching filter" do
            group = ExampleGroup.describe("does something")
            group.stub(:world) { world }
            filtered_examples = [
              group.example("first", spec_metadata),
              group.example("second", spec_metadata)
            ]
            unfiltered_example = group.example("third (not-filtered)")

            group.filtered_examples.should == [unfiltered_example]
          end
        end
      end

      context "matching false" do
        let(:spec_metadata)    { { :awesome => false }}

        context "against false" do
          let(:filter_metadata)  { { :awesome => false }}
          include_examples "matching filters"
        end

        context "against 'false'" do
          let(:filter_metadata)  { { :awesome => 'false' }}
          include_examples "matching filters"
        end

        context "against :false" do
          let(:filter_metadata)  { { :awesome => :false }}
          include_examples "matching filters"
        end
      end

      context "matching true" do
        let(:spec_metadata)    { { :awesome => true }}

        context "against true" do
          let(:filter_metadata)  { { :awesome => true }}
          include_examples "matching filters"
        end

        context "against 'true'" do
          let(:filter_metadata)  { { :awesome => 'true' }}
          include_examples "matching filters"
        end

        context "against :true" do
          let(:filter_metadata)  { { :awesome => :true }}
          include_examples "matching filters"
        end
      end

      context "matching a string" do
        let(:spec_metadata)    { { :type => 'special' }}

        context "against a string" do
          let(:filter_metadata)  { { :type => 'special' }}
          include_examples "matching filters"
        end

        context "against a symbol" do
          let(:filter_metadata)  { { :type => :special }}
          include_examples "matching filters"
        end
      end

      context "matching a symbol" do
        let(:spec_metadata)    { { :type => :special }}

        context "against a string" do
          let(:filter_metadata)  { { :type => 'special' }}
          include_examples "matching filters"
        end

        context "against a symbol" do
          let(:filter_metadata)  { { :type => :special }}
          include_examples "matching filters"
        end
      end

      context "with no filters" do
        it "returns all" do
          group = ExampleGroup.describe
          group.stub(:world) { world }
          example = group.example("does something")
          group.filtered_examples.should == [example]
        end
      end

      context "with no examples or groups that match filters" do
        it "returns none" do
          world.stub(:inclusion_filter).and_return({ :awesome => false })
          group = ExampleGroup.describe
          group.stub(:world) { world }
          example = group.example("does something")
          group.filtered_examples.should == []
        end
      end
    end

    describe '#describes' do

      context "with a constant as the first parameter" do
        it "is that constant" do
          ExampleGroup.describe(Object) { }.describes.should == Object
        end
      end

      context "with a string as the first parameter" do
        it "is nil" do
          ExampleGroup.describe("i'm a computer") { }.describes.should be_nil
        end
      end

      context "with a constant in an outer group" do
        context "and a string in an inner group" do
          it "is the top level constant" do
            group = ExampleGroup.describe(String) do
              describe :symbol do
                example "describes is String" do
                  described_class.should eq(String)
                end
              end
            end

            group.run.should be_true
          end
        end
      end

      context "in a nested group" do
        it "inherits the described class/module from the outer group" do
          group = ExampleGroup.describe(String) do
            describe Array do
              example "desribes is String" do
                described_class.should eq(String)
              end
            end
          end

          group.run.should be_true, "expected examples in group to pass"
        end
      end
    end

    describe '#described_class' do
      it "is the same as describes" do
        self.class.described_class.should eq(self.class.describes)
      end
    end

    describe '#description' do
      it "grabs the description from the metadata" do
        group = ExampleGroup.describe(Object, "my desc") { }
        group.description.should == group.metadata[:example_group][:description]
      end
    end

    describe '#metadata' do
      it "adds the third parameter to the metadata" do
        ExampleGroup.describe(Object, nil, 'foo' => 'bar') { }.metadata.should include({ "foo" => 'bar' })
      end

      it "adds the the file_path to metadata" do
        ExampleGroup.describe(Object) { }.metadata[:example_group][:file_path].should == __FILE__
      end

      it "has a reader for file_path" do
        ExampleGroup.describe(Object) { }.file_path.should == __FILE__
      end

      it "adds the line_number to metadata" do
        ExampleGroup.describe(Object) { }.metadata[:example_group][:line_number].should == __LINE__
      end
    end

    [:focus, :focused].each do |example_alias|
      describe "##{example_alias}" do
        let(:group) { ExampleGroup.describe }
        subject { group.send example_alias, "a focused example" }

        it 'defines an example that can be filtered with :focused => true' do
          subject.metadata.should include(:focused => true)
        end

        it 'defines an example that can be filtered with :focus => true' do
          subject.metadata.should include(:focus => true)
        end
      end
    end

    describe "#before, after, and around hooks" do
      it "runs the before alls in order" do
        group = ExampleGroup.describe
        order = []
        group.before(:all) { order << 1 }
        group.before(:all) { order << 2 }
        group.before(:all) { order << 3 }
        group.example("example") {}

        group.run

        order.should eq([1,2,3])
      end

      it "runs the before eachs in order" do
        group = ExampleGroup.describe
        order = []
        group.before(:each) { order << 1 }
        group.before(:each) { order << 2 }
        group.before(:each) { order << 3 }
        group.example("example") {}

        group.run

        order.should eq([1,2,3])
      end

      it "runs the after eachs in reverse order" do
        group = ExampleGroup.describe
        order = []
        group.after(:each) { order << 1 }
        group.after(:each) { order << 2 }
        group.after(:each) { order << 3 }
        group.example("example") {}

        group.run

        order.should eq([3,2,1])
      end

      it "runs the after alls in reverse order" do
        group = ExampleGroup.describe
        order = []
        group.after(:all) { order << 1 }
        group.after(:all) { order << 2 }
        group.after(:all) { order << 3 }
        group.example("example") {}

        group.run

        order.should eq([3,2,1])
      end

      it "only runs before/after(:all) hooks from example groups that have specs that run" do
        hooks_run = []

        RSpec.configure do |c|
          c.filter_run :focus => true
        end

        unfiltered_group = ExampleGroup.describe "unfiltered" do
          before(:all) { hooks_run << :unfiltered_before_all }
          after(:all)  { hooks_run << :unfiltered_after_all  }

          context "a subcontext" do
            it("has an example") { }
          end
        end

        filtered_group = ExampleGroup.describe "filtered", :focus => true do
          before(:all) { hooks_run << :filtered_before_all }
          after(:all)  { hooks_run << :filtered_after_all  }

          context "a subcontext" do
            it("has an example") { }
          end
        end

        unfiltered_group.run
        filtered_group.run

        hooks_run.should eq([:filtered_before_all, :filtered_after_all])
      end

      it "runs before_all_defined_in_config, before all, before each, example, after each, after all, after_all_defined_in_config in that order" do
        order = []

        RSpec.configure do |c|
          c.before(:all) { order << :before_all_defined_in_config }
          c.after(:all) { order << :after_all_defined_in_config }
        end

        group = ExampleGroup.describe
        group.before(:all)  { order << :top_level_before_all  }
        group.before(:each) { order << :before_each }
        group.after(:each)  { order << :after_each  }
        group.after(:all)   { order << :top_level_after_all   }
        group.example("top level example") { order << :top_level_example }

        context1 = group.describe("context 1")
        context1.before(:all) { order << :nested_before_all }
        context1.example("nested example 1") { order << :nested_example_1 }

        context2 = group.describe("context 2")
        context2.after(:all) { order << :nested_after_all }
        context2.example("nested example 2") { order << :nested_example_2 }

        group.run

        order.should == [
          :before_all_defined_in_config,
          :top_level_before_all,
          :before_each,
          :top_level_example,
          :after_each,
          :nested_before_all,
          :before_each,
          :nested_example_1,
          :after_each,
          :before_each,
          :nested_example_2,
          :after_each,
          :nested_after_all,
          :top_level_after_all,
          :after_all_defined_in_config
        ]
      end

      context "after(:all)" do
        let(:outer) { ExampleGroup.describe }
        let(:inner) { outer.describe }

        it "has access to state defined before(:all)" do
          outer.before(:all) { @outer = "outer" }
          inner.before(:all) { @inner = "inner" }

          outer.after(:all) do
            @outer.should eq("outer")
            @inner.should eq("inner")
          end
          inner.after(:all) do
            @inner.should eq("inner")
            @outer.should eq("outer")
          end

          outer.run
        end

        it "cleans up ivars in after(:all)" do
          outer.before(:all) { @outer = "outer" }
          inner.before(:all) { @inner = "inner" }

          outer.run

          inner.before_all_ivars[:@inner].should be_nil
          inner.before_all_ivars[:@outer].should be_nil
          outer.before_all_ivars[:@inner].should be_nil
          outer.before_all_ivars[:@outer].should be_nil
        end
      end

      it "treats an error in before(:each) as a failure" do
        group = ExampleGroup.describe
        group.before(:each) { raise "error in before each" }
        example = group.example("equality") { 1.should == 2}
        group.run.should == false

        example.metadata[:execution_result][:exception].message.should == "error in before each"
      end

      it "treats an error in before(:all) as a failure" do
        group = ExampleGroup.describe
        group.before(:all) { raise "error in before all" }
        example = group.example("equality") { 1.should == 2}
        group.run.should == false

        example.metadata.should_not be_nil
        example.metadata[:execution_result].should_not be_nil
        example.metadata[:execution_result][:exception].should_not be_nil
        example.metadata[:execution_result][:exception].message.should == "error in before all"
      end

      it "treats an error in before(:all) as a failure for a spec in a nested group" do
        example = nil
        group = ExampleGroup.describe do
          before(:all) { raise "error in before all" }

          describe "nested" do
            example = it("equality") { 1.should == 2}
          end
        end
        group.run

        example.metadata.should_not be_nil
        example.metadata[:execution_result].should_not be_nil
        example.metadata[:execution_result][:exception].should_not be_nil
        example.metadata[:execution_result][:exception].message.should == "error in before all"
      end

      context "when an error occurs in an after(:all) hook" do
        before(:each) do
          RSpec.configuration.reporter.stub(:message)
        end

        let(:group) do
          ExampleGroup.describe do
            after(:all) { raise "error in after all" }
            it("equality") { 1.should == 1 }
          end
        end

        it "allows the example to pass" do
          group.run
          example = group.examples.first
          example.metadata.should_not be_nil
          example.metadata[:execution_result].should_not be_nil
          example.metadata[:execution_result][:status].should == "passed"
        end

        it "rescues the error and prints it out" do
          RSpec.configuration.reporter.should_receive(:message).with(/error in after all/)
          group.run
        end
      end

      it "has no 'running example' within before(:all)" do
        group = ExampleGroup.describe
        running_example = :none
        group.before(:all) { running_example = example }
        group.example("no-op") { }
        group.run
        running_example.should == nil
      end

      it "has access to example options within before(:each)" do
        group = ExampleGroup.describe
        option = nil
        group.before(:each) { option = example.options[:data] }
        group.example("no-op", :data => :sample) { }
        group.run
        option.should == :sample
      end

      it "has access to example options within after(:each)" do
        group = ExampleGroup.describe
        option = nil
        group.after(:each) { option = example.options[:data] }
        group.example("no-op", :data => :sample) { }
        group.run
        option.should == :sample
      end

      it "has no 'running example' within after(:all)" do
        group = ExampleGroup.describe
        running_example = :none
        group.after(:all) { running_example = example }
        group.example("no-op") { }
        group.run
        running_example.should == nil
      end
    end

    describe "adding examples" do

      it "allows adding an example using 'it'" do
        group = ExampleGroup.describe
        group.it("should do something") { }
        group.examples.size.should == 1
      end

      it "allows adding a pending example using 'xit'" do
        group = ExampleGroup.describe
        group.xit("is pending") { }
        group.run
        group.examples.first.should be_pending
      end

      it "exposes all examples at examples" do
        group = ExampleGroup.describe
        group.it("should do something 1") { }
        group.it("should do something 2") { }
        group.it("should do something 3") { }
        group.should have(3).examples
      end

      it "maintains the example order" do
        group = ExampleGroup.describe
        group.it("should 1") { }
        group.it("should 2") { }
        group.it("should 3") { }
        group.examples[0].description.should == 'should 1'
        group.examples[1].description.should == 'should 2'
        group.examples[2].description.should == 'should 3'
      end

    end

    describe Object, "describing nested example_groups", :little_less_nested => 'yep' do

      describe "A sample nested group", :nested_describe => "yep" do
        it "sets the described class to the described class of the outer most group" do
          example.example_group.describes.should eq(ExampleGroup)
        end

        it "sets the description to 'A sample nested describe'" do
          example.example_group.description.should == 'A sample nested group'
        end

        it "has top level metadata from the example_group and its ancestors" do
          example.example_group.metadata.should include(:little_less_nested => 'yep', :nested_describe => 'yep')
        end

        it "exposes the parent metadata to the contained examples" do
          example.metadata.should include(:little_less_nested => 'yep', :nested_describe => 'yep')
        end
      end

    end

    describe "#run_examples" do

      let(:reporter) { double("reporter").as_null_object }

      it "returns true if all examples pass" do
        group = ExampleGroup.describe('group') do
          example('ex 1') { 1.should == 1 }
          example('ex 2') { 1.should == 1 }
        end
        group.stub(:filtered_examples) { group.examples }
        group.run(reporter).should be_true
      end

      it "returns false if any of the examples fail" do
        group = ExampleGroup.describe('group') do
          example('ex 1') { 1.should == 1 }
          example('ex 2') { 1.should == 2 }
        end
        group.stub(:filtered_examples) { group.examples }
        group.run(reporter).should be_false
      end

      it "runs all examples, regardless of any of them failing" do
        group = ExampleGroup.describe('group') do
          example('ex 1') { 1.should == 2 }
          example('ex 2') { 1.should == 1 }
        end
        group.stub(:filtered_examples) { group.examples }
        group.filtered_examples.each do |example|
          example.should_receive(:run)
        end
        group.run(reporter).should be_false
      end
    end

    describe "how instance variables are inherited" do
      before(:all) do
        @before_all_top_level = 'before_all_top_level'
      end

      before(:each) do
        @before_each_top_level = 'before_each_top_level'
      end

      it "can access a before each ivar at the same level" do
        @before_each_top_level.should == 'before_each_top_level'
      end

      it "can access a before all ivar at the same level" do
        @before_all_top_level.should == 'before_all_top_level'
      end

      it "can access the before all ivars in the before_all_ivars hash", :ruby => 1.8 do
        example.example_group.before_all_ivars.should include('@before_all_top_level' => 'before_all_top_level')
      end

      it "can access the before all ivars in the before_all_ivars hash", :ruby => 1.9 do
        example.example_group.before_all_ivars.should include(:@before_all_top_level => 'before_all_top_level')
      end

      describe "but now I am nested" do
        it "can access a parent example groups before each ivar at a nested level" do
          @before_each_top_level.should == 'before_each_top_level'
        end

        it "can access a parent example groups before all ivar at a nested level" do
          @before_all_top_level.should == "before_all_top_level"
        end

        it "changes to before all ivars from within an example do not persist outside the current describe" do
          @before_all_top_level = "ive been changed"
        end

        describe "accessing a before_all ivar that was changed in a parent example_group" do
          it "does not have access to the modified version" do
            @before_all_top_level.should == 'before_all_top_level'
          end
        end
      end

    end

    describe "ivars are not shared across examples" do
      it "(first example)" do
        @a = 1
        @b.should be_nil
      end

      it "(second example)" do
        @b = 2
        @a.should be_nil
      end
    end


    describe "#top_level_description" do
      it "returns the description from the outermost example group" do
        group = nil
        ExampleGroup.describe("top") do
          context "middle" do
            group = describe "bottom" do
            end
          end
        end

        group.top_level_description.should == "top"
      end
    end

    describe "#run" do
      let(:reporter) { double("reporter").as_null_object }

      context "with fail_fast? => true" do
        it "does not run examples after the failed example" do
          group = RSpec::Core::ExampleGroup.describe
          group.stub(:fail_fast?) { true }
          examples_run = []
          group.example('example 1') { examples_run << self }
          group.example('example 2') { examples_run << self; fail; }
          group.example('example 3') { examples_run << self }

          group.run

          examples_run.length.should eq(2)
        end
      end

      context "with RSpec.wants_to_quit=true" do
        let(:group) { RSpec::Core::ExampleGroup.describe }

        before do
          RSpec.stub(:wants_to_quit) { true }
          RSpec.stub(:clear_remaining_example_groups)
        end

        it "returns without starting the group" do
          reporter.should_not_receive(:example_group_started)
          group.run(reporter)
        end

        context "at top level" do
          it "purges remaining groups" do
            RSpec.should_receive(:clear_remaining_example_groups)
            group.run(reporter)
          end
        end

        context "in a nested group" do
          it "does not purge remaining groups" do
            nested_group = group.describe
            RSpec.should_not_receive(:clear_remaining_example_groups)
            nested_group.run(reporter)
          end
        end
      end

      context "with all examples passing" do
        it "returns true" do
          group = describe("something") do
            it "does something" do
              # pass
            end
            describe ("nested") do
              it "does something else" do
                # pass
              end
            end
          end

          group.run(reporter).should be_true
        end
      end

      context "with top level example failing" do
        it "returns false" do
          group = describe("something") do
            it "does something (wrong - fail)" do
              raise "fail"
            end
            describe ("nested") do
              it "does something else" do
                # pass
              end
            end
          end

          group.run(reporter).should be_false
        end
      end

      context "with nested example failing" do
        it "returns true" do
          group = describe("something") do
            it "does something" do
              # pass
            end
            describe ("nested") do
              it "does something else (wrong -fail)" do
                raise "fail"
              end
            end
          end

          group.run(reporter).should be_false
        end
      end
    end

    describe "#include_context" do
      before do
        shared_context "named this" do
          def foo; 'foo'; end
        end
      end

      it "includes the named context" do
        group = ExampleGroup.describe do
          include_context "named this"
          it "accesses foo" do
            foo.should eq('foo')
          end
        end
        group.run.should be_true
      end
    end

    describe "#include_examples" do
      before do
        shared_examples "named this" do
          example("does something") do
          end
        end
      end

      it "includes the named examples" do
        group = ExampleGroup.describe do
          include_examples "named this"
        end
        group.examples.first.description.should eq("does something")
      end
    end

  end
end
