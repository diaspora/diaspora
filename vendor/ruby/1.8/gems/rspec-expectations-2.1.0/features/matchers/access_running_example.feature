Feature: Access running example

  In order to take advantage of services that are available
    in my examples when I'm writing matchers
  As a spec author
  I want to call methods on the running example

  If the method exists in the context of the example, it gets
  called. If not, a NoMethodError is raised on the Matcher itself
  (not the example).

  Scenario: call method defined on example from matcher
    Given a file named "example_spec.rb" with:
      """
      RSpec::Matchers.define :bar do
        match do |_|
          foo == "foo"
        end
      end

      describe "something" do
        def foo
          "foo"
        end

        it "does something" do
          "foo".should bar
        end
      end
      """
    When I run "rspec ./example_spec.rb"
    Then the output should contain "1 example, 0 failures"

  Scenario: call method _not_ defined on example from matcher
    Given a file named "example_spec.rb" with:
      """
      RSpec::Matchers.define :bar do
        match do |_|
          foo == "foo"
        end
      end

      describe "something" do
        it "does something" do
          "foo".should bar
        end
      end
      """
    When I run "rspec ./example_spec.rb"
    Then the output should contain "1 example, 1 failure"
    And the output should contain "undefined local variable"
    And the output should contain "RSpec::Matchers::Matcher"
    And the output should not contain "ExampleGroup"
