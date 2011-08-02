Feature: filters

  `before`/`after`/`around` hooks defined in the RSpec configuration block can
  be filtered using metadata.  Arbitrary metadata can be applied to an example
  or example group, and used to make a hook only apply to examples with the
  given metadata.

  If you set the `treat_symbols_as_metadata_keys_with_true_values` config option
  to `true`, you can specify metadata using only symbols.

  Scenario: filter `before(:each)` hooks using arbitrary metadata
    Given a file named "filter_before_each_hooks_spec.rb" with:
      """
      RSpec.configure do |config|
        config.before(:each, :foo => :bar) do
          invoked_hooks << :before_each_foo_bar
        end
      end

      describe "a filtered before :each hook" do
        let(:invoked_hooks) { [] }

        describe "group without matching metadata" do
          it "does not run the hook" do
            invoked_hooks.should be_empty
          end

          it "runs the hook for an example with matching metadata", :foo => :bar do
            invoked_hooks.should == [:before_each_foo_bar]
          end
        end

        describe "group with matching metadata", :foo => :bar do
          it "runs the hook" do
            invoked_hooks.should == [:before_each_foo_bar]
          end
        end
      end
      """
    When I run `rspec filter_before_each_hooks_spec.rb`
    Then the examples should all pass

  Scenario: filter `after(:each)` hooks using arbitrary metadata
    Given a file named "filter_after_each_hooks_spec.rb" with:
      """
      RSpec.configure do |config|
        config.after(:each, :foo => :bar) do
          raise "boom!"
        end
      end

      describe "a filtered after :each hook" do
        describe "group without matching metadata" do
          it "does not run the hook" do
            # should pass
          end

          it "runs the hook for an example with matching metadata", :foo => :bar do
            # should fail
          end
        end

        describe "group with matching metadata", :foo => :bar do
          it "runs the hook" do
            # should fail
          end
        end
      end
      """
    When I run `rspec filter_after_each_hooks_spec.rb`
    Then the output should contain "3 examples, 2 failures"

  Scenario: filter around(:each) hooks using arbitrary metadata
    Given a file named "filter_around_each_hooks_spec.rb" with:
      """
      RSpec.configure do |config|
        config.around(:each, :foo => :bar) do |example|
          order << :before_around_each_foo_bar
          example.run
          order.should == [:before_around_each_foo_bar, :example]
        end
      end

      describe "a filtered around(:each) hook" do
        let(:order) { [] }

        describe "a group without matching metadata" do
          it "does not run the hook" do
            order.should be_empty
          end

          it "runs the hook for an example with matching metadata", :foo => :bar do
            order.should == [:before_around_each_foo_bar]
            order << :example
          end
        end

        describe "a group with matching metadata", :foo => :bar do
          it "runs the hook for an example with matching metadata", :foo => :bar do
            order.should == [:before_around_each_foo_bar]
            order << :example
          end
        end
      end
      """
    When I run `rspec filter_around_each_hooks_spec.rb`
    Then the examples should all pass

  Scenario: filter before(:all) hooks using arbitrary metadata
    Given a file named "filter_before_all_hooks_spec.rb" with:
      """
      RSpec.configure do |config|
        config.before(:all, :foo => :bar) { @hook = :before_all_foo_bar }
      end

      describe "a filtered before(:all) hook" do
        describe "a group without matching metadata" do
          it "does not run the hook" do
            @hook.should be_nil
          end

          describe "a nested subgroup with matching metadata", :foo => :bar do
            it "runs the hook" do
              @hook.should == :before_all_foo_bar
            end
          end
        end

        describe "a group with matching metadata", :foo => :bar do
          it "runs the hook" do
            @hook.should == :before_all_foo_bar
          end

          describe "a nested subgroup" do
            it "runs the hook" do
              @hook.should == :before_all_foo_bar
            end
          end
        end
      end
      """
    When I run `rspec filter_before_all_hooks_spec.rb`
    Then the examples should all pass

  Scenario: filter after(:all) hooks using arbitrary metadata
    Given a file named "filter_after_all_hooks_spec.rb" with:
      """
      example_msgs = []

      RSpec.configure do |config|
        config.after(:all, :foo => :bar) do
          puts "after :all"
        end
      end

      describe "a filtered after(:all) hook" do
        describe "a group without matching metadata" do
          it "does not run the hook" do
            puts "unfiltered"
          end
        end

        describe "a group with matching metadata", :foo => :bar do
          it "runs the hook" do
            puts "filtered 1"
          end
        end

        describe "another group without matching metadata" do
          describe "a nested subgroup with matching metadata", :foo => :bar do
            it "runs the hook" do
              puts "filtered 2"
            end
          end
        end
      end
      """
    When I run `rspec filter_after_all_hooks_spec.rb`
    Then the examples should all pass
    And the output should contain:
      """
      unfiltered
      .filtered 1
      .after :all
      filtered 2
      .after :all
      """

  Scenario: Use symbols as metadata
    Given a file named "less_verbose_metadata_filter.rb" with:
      """
      RSpec.configure do |c|
        c.treat_symbols_as_metadata_keys_with_true_values = true
        c.before(:each, :before_each) { puts "before each" }
        c.after(:each,  :after_each) { puts "after each" }
        c.around(:each, :around_each) do |example|
          puts "around each (before)"
          example.run
          puts "around each (after)"
        end
        c.before(:all, :before_all) { puts "before all" }
        c.after(:all,  :after_all) { puts "after all" }
      end

      describe "group 1", :before_all, :after_all do
        it("") { puts "example 1" }
        it("", :before_each) { puts "example 2" }
        it("", :after_each) { puts "example 3" }
        it("", :around_each) { puts "example 4" }
      end
      """
    When I run `rspec less_verbose_metadata_filter.rb`
    Then the examples should all pass
    And the output should contain:
      """
      before all
      example 1
      .before each
      example 2
      .example 3
      after each
      .around each (before)
      example 4
      around each (after)
      .after all
      """

