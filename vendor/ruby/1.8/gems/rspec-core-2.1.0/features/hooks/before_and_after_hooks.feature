Feature: before and after hooks

  As a developer using RSpec
  I want to execute arbitrary code before and after each example
  So that I can control the environment in which it is run

    This is supported by the before and after methods which each take a symbol
    indicating the scope, and a block of code to execute.

    before(:each) blocks are run before each example
    before(:all) blocks are run once before all of the examples in a group

    after(:each) blocks are run after each example
    after(:all) blocks are run once after all of the examples in a group

    Before and after blocks are called in the following order:
      before suite
      before all
      before each
      after  each
      after  all
      after  suite

    Before and after blocks can be defined in the example groups to which they
    apply or in a configuration. When defined in a configuration, they can be
    applied to all groups or subsets of all groups defined by example group
    types.

  Scenario: define before(:each) block
    Given a file named "before_each_spec.rb" with:
      """
      require "rspec/expectations"

      class Thing
        def widgets
          @widgets ||= []
        end
      end

      describe Thing do
        before(:each) do
          @thing = Thing.new
        end

        describe "initialized in before(:each)" do
          it "has 0 widgets" do
            @thing.should have(0).widgets
          end

          it "can get accept new widgets" do
            @thing.widgets << Object.new
          end

          it "does not share state across examples" do
            @thing.should have(0).widgets
          end
        end
      end
      """
    When I run "rspec ./before_each_spec.rb"
    Then the output should contain "3 examples, 0 failures"

  Scenario: define before(:all) block in example group
    Given a file named "before_all_spec.rb" with:
      """
      require "rspec/expectations"

      class Thing
        def widgets
          @widgets ||= []
        end
      end
  
      describe Thing do
        before(:all) do
          @thing = Thing.new
        end
  
        describe "initialized in before(:all)" do
          it "has 0 widgets" do
            @thing.should have(0).widgets
          end
  
          it "can get accept new widgets" do
            @thing.widgets << Object.new
          end
  
          it "shares state across examples" do
            @thing.should have(1).widgets
          end
        end
      end
      """
    When I run "rspec ./before_all_spec.rb"
    Then the output should contain "3 examples, 0 failures"

    When I run "rspec ./before_all_spec.rb:15"
    Then the output should contain "1 example, 0 failures"

  Scenario: failure in before(:all) block
    Given a file named "before_all_spec.rb" with:
      """
      describe "an error in before(:all)" do
        before(:all) do
          raise "oops"
        end

        it "fails this example" do
        end

        it "fails this example, too" do
        end

        after(:all) do
          puts "after all ran"
        end

        describe "nested group" do
          it "fails this third example" do
          end

          it "fails this fourth example" do
          end

          describe "yet another level deep" do
            it "fails this last example" do
            end
          end
        end
      end
      """
    When I run "rspec ./before_all_spec.rb --format documentation"
    Then the output should contain "5 examples, 5 failures"
    And the output should contain:
      """
      an error in before(:all)
        fails this example (FAILED - 1)
        fails this example, too (FAILED - 2)
        nested group
          fails this third example (FAILED - 3)
          fails this fourth example (FAILED - 4)
          yet another level deep
            fails this last example (FAILED - 5)
      after all ran
      """

    When I run "rspec ./before_all_spec.rb:9 --format documentation"
    Then the output should contain "1 example, 1 failure"
    And the output should contain:
      """
      an error in before(:all)
        fails this example, too (FAILED - 1)
        nested group
          yet another level deep
      after all ran
      """

  Scenario: failure in after(:all) block
    Given a file named "after_all_spec.rb" with:
      """
      describe "an error in after(:all)" do
        after(:all) do
          raise StandardError.new("Boom!")
        end

        it "passes this example" do
        end

        it "passes this example, too" do
        end
      end
      """
    When I run "rspec after_all_spec.rb"
    Then the output should contain "2 examples, 0 failures"
    And the output should contain:
      """
      An error occurred in an after(:all) hook.
        StandardError: Boom!
      """

  Scenario: define before and after blocks in configuration
    Given a file named "befores_in_configuration_spec.rb" with:
      """
      require "rspec/expectations"

      RSpec.configure do |config|
        config.before(:each) do
          @before_each = "before each"
        end
        config.before(:all) do
          @before_all = "before all"
        end
      end
  
      describe "stuff in before blocks" do
        describe "with :all" do
          it "should be available in the example" do
            @before_all.should == "before all"
          end
        end
        describe "with :each" do
          it "should be available in the example" do
            @before_each.should == "before each"
          end
        end
      end
      """
    When I run "rspec ./befores_in_configuration_spec.rb"
    Then the output should contain "2 examples, 0 failures"

  Scenario: before/after blocks are run in order
    Given a file named "ensure_block_order_spec.rb" with:
      """
      require "rspec/expectations"

      describe "before and after callbacks" do
        before(:all) do
          puts "before all"
        end
  
        before(:each) do
          puts "before each"
        end
  
        after(:each) do
          puts "after each"
        end
  
        after(:all) do
          puts "after all"
        end
  
        it "gets run in order" do
  
        end
      end
      """
    When I run "rspec ./ensure_block_order_spec.rb"
    Then the output should contain:
      """
      before all
      before each
      after each
      .after all
      """
  
  Scenario: before/after blocks defined in config are run in order
    Given a file named "configuration_spec.rb" with:
      """
      require "rspec/expectations"

      RSpec.configure do |config|
        config.before(:suite) do
          puts "before suite"
        end
  
        config.before(:all) do
          puts "before all"
        end
  
        config.before(:each) do
          puts "before each"
        end
  
        config.after(:each) do
          puts "after each"
        end
  
        config.after(:all) do
          puts "after all"
        end
  
        config.after(:suite) do
          puts "after suite"
        end
      end
  
      describe "ignore" do
        example "ignore" do
        end
      end
      """
    When I run "rspec configuration_spec.rb"
    Then the output should contain:
      """
      before suite
      before all
      before each
      after each
      .after all
      after suite
      """

  Scenario: before/after all blocks are run once
    Given a file named "before_and_after_all_spec.rb" with:
      """
      describe "before and after callbacks" do
        before(:all) do
          puts "outer before all"
        end
  
        example "in outer group" do
        end

        after(:all) do
          puts "outer after all"
        end

        describe "nested group" do
          before(:all) do
            puts "inner before all"
          end
          
          example "in nested group" do
          end

          after(:all) do
            puts "inner after all"
          end
        end

      end
      """
    When I run "rspec ./before_and_after_all_spec.rb"
    Then the output should contain "2 examples, 0 failures"
    And the output should contain:
      """
      outer before all
      .inner before all
      .inner after all
      outer after all
      """

    When I run "rspec ./before_and_after_all_spec.rb:14"
    Then the output should contain "1 example, 0 failures"
    And the output should contain:
      """
      outer before all
      inner before all
      .inner after all
      outer after all
      """

    When I run "rspec ./before_and_after_all_spec.rb:6"
    Then the output should contain "1 example, 0 failures"
    And the output should contain:
      """
      outer before all
      .outer after all
      """

  Scenario: nested examples have access to state set in outer before(:all)
    Given a file named "before_all_spec.rb" with:
      """
      describe "something" do
        before :all do
          @value = 123
        end

        describe "nested" do
          it "access state set in before(:all)" do
            @value.should eq(123)
          end

          describe "nested more deeply" do
            it "access state set in before(:all)" do
              @value.should eq(123)
            end
          end
        end

        describe "nested in parallel" do
          it "access state set in before(:all)" do
            @value.should == 123
          end
        end
      end
      """
    When I run "rspec before_all_spec.rb"
    Then the output should contain "3 examples, 0 failures"

  Scenario: before/after all blocks have access to state
    Given a file named "before_and_after_all_spec.rb" with:
      """
      describe "before and after callbacks" do
        before(:all) do
          @outer_state = "set in outer before all"
        end

        example "in outer group" do
          @outer_state.should eq("set in outer before all")
        end

        describe "nested group" do
          before(:all) do
            @inner_state = "set in inner before all"
          end

          example "in nested group" do
            @outer_state.should eq("set in outer before all")
            @inner_state.should eq("set in inner before all")
          end

          after(:all) do
            @inner_state.should eq("set in inner before all")
          end
        end

        after(:all) do
          # p @outer_state.nil?
          @outer_state.should eq("set in outer before all")
        end
      end
      """
    When I run "rspec ./before_and_after_all_spec.rb"
    Then the output should contain "2 examples, 0 failures"

  Scenario: exception in before(:each) is captured and reported as failure
    Given a file named "error_in_before_each_spec.rb" with:
      """
      describe "error in before(:each)" do
        before(:each) do
          raise "this error"
        end

        it "is reported as failure" do
        end
      end
      """
    When I run "rspec ./error_in_before_each_spec.rb"
    Then the output should contain "1 example, 1 failure"
    And the output should contain "this error"
