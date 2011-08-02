Feature: exclusion filters

  You can exclude examples from a run by declaring an exclusion filter and
  then tagging examples, or entire groups, with that filter.

  If you set the `treat_symbols_as_metadata_keys_with_true_values` config option
  to `true`, you can specify metadata using only symbols.
  
  Scenario: exclude an example
    Given a file named "spec/sample_spec.rb" with:
      """
      RSpec.configure do |c|
        # declare an exclusion filter
        c.filter_run_excluding :broken => true
      end

      describe "something" do
        it "does one thing" do
        end

        # tag example for exclusion by adding metadata
        it "does another thing", :broken => true do
        end
      end
      """
    When I run `rspec ./spec/sample_spec.rb --format doc`
    Then the output should contain "does one thing"
    And the output should not contain "does another thing"

  Scenario: exclude a group
    Given a file named "spec/sample_spec.rb" with:
      """
      RSpec.configure do |c|
        c.filter_run_excluding :broken => true
      end
  
      describe "group 1", :broken => true do
        it "group 1 example 1" do
        end
  
        it "group 1 example 2" do
        end
      end
  
      describe "group 2" do
        it "group 2 example 1" do
        end
      end
      """
    When I run `rspec ./spec/sample_spec.rb --format doc`
    Then the output should contain "group 2 example 1"
    And  the output should not contain "group 1 example 1"
    And  the output should not contain "group 1 example 2"
  
  Scenario: exclude multiple groups
    Given a file named "spec/sample_spec.rb" with:
      """
      RSpec.configure do |c|
        c.filter_run_excluding :broken => true
      end
  
      describe "group 1", :broken => true do
        before(:all) do
          raise "you should not see me"
        end
        
        it "group 1 example 1" do
        end
  
        it "group 1 example 2" do
        end
      end
  
      describe "group 2", :broken => true do
        before(:each) do
          raise "you should not see me"
        end
        
        it "group 2 example 1" do
        end
      end
      """
    When I run `rspec ./spec/sample_spec.rb --format doc`
    Then the output should match /No examples were matched. Perhaps \{.*:broken=>true.*\} is excluding everything?/
    And  the examples should all pass
    And  the output should not contain "group 1"
    And  the output should not contain "group 2"

  Scenario: before/after(:all) hooks in excluded example group are not run
    Given a file named "spec/before_after_all_exclusion_filter_spec.rb" with:
      """
      RSpec.configure do |c|
        c.filter_run_excluding :broken => true
      end

      describe "group 1" do
        before(:all) { puts "before all in included group" }
        after(:all)  { puts "after all in included group"  }

        it "group 1 example" do
        end
      end

      describe "group 2", :broken => true do
        before(:all) { puts "before all in excluded group" }
        after(:all)  { puts "after all in excluded group"  }

        context "context 1" do
          it "group 2 context 1 example 1" do
          end
        end
      end
      """
    When I run `rspec ./spec/before_after_all_exclusion_filter_spec.rb`
    Then the output should contain "before all in included group"
     And the output should contain "after all in included group"
     And the output should not contain "before all in excluded group"
     And the output should not contain "after all in excluded group"

  Scenario: Use symbols as metadata
    Given a file named "symbols_as_metadata_spec.rb" with:
      """
      RSpec.configure do |c|
        c.treat_symbols_as_metadata_keys_with_true_values = true
        c.filter_run_excluding :broken
      end

      describe "something" do
        it "does one thing" do
        end

        # tag example for exclusion by adding metadata
        it "does another thing", :broken do
        end
      end
      """
    When I run `rspec symbols_as_metadata_spec.rb --format doc`
    Then the output should contain "does one thing"
    And the output should not contain "does another thing"
