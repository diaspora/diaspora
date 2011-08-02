Feature: define diffable matcher

  When a matcher is defined as diffable, and the --diff
  flag is set, the output will include a diff of the submitted
  objects.

  @wip
  Scenario: define a diffable matcher
    Given a file named "diffable_matcher_spec.rb" with:
      """
      RSpec::Matchers.define :be_just_like do |expected|
        match do |actual|
          actual == expected
        end
        
        diffable
      end

      describe "this" do
        it {should be_just_like("that")}
      end
      """
    When I run `rspec ./diffable_matcher_spec.rb --diff`
    Then the exit status should not be 0

    And the output should contain "should be just like that"
    And the output should contain "Diff:\n@@ -1,2 +1,2 @@\n-that\n+this"
