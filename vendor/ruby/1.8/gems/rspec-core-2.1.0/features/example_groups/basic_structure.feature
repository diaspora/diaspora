Feature: basic structure

  RSpec provides a DSL for creating executable examples of how code is expected
  to behave, organized in groups. It uses the words "describe" and "it" so we can
  express concepts like a conversation:

    "Describe an account when it is first opened."
    "It has a balance of zero."

  Use the describe() method to declare an example group. This defines a
  subclass of RSpec's ExampleGroup class. Within a group, you can declare
  nested groups using the describe() or context() methods.

  Use the it() method to declare an example. This, effectively, defines a
  method that is run in an instance of the group in which it is declared.

  Scenario: one group, one example
    Given a file named "sample_spec.rb" with:
    """
    describe "something" do
      it "does something" do
      end
    end
    """
    When I run "rspec sample_spec.rb -fn"
    Then the output should contain:
      """
      something
        does something
      """

  Scenario: nested example groups (using context)
    Given a file named "nested_example_groups_spec.rb" with:
    """
    describe "something" do
      context "in one context" do
        it "does one thing" do
        end
      end
      context "in another context" do
        it "does another thing" do
        end
      end
    end
    """
    When I run "rspec nested_example_groups_spec.rb -fdoc"
    Then the output should contain:
      """
      something
        in one context
          does one thing
        in another context
          does another thing
      """
