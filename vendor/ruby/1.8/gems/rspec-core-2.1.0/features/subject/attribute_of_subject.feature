Feature: attribute of subject

  Use the its() method as a short-hand to generate a nested example group with
  a single example that specifies the expected value of an attribute of the subject.
  This can be used with an implicit or explicit subject.

  its() accepts a symbol or a string, and a block representing the example. Use
  a string with dots to specify a nested attribute (i.e. an attribute of the
  attribute of the subject).

  Scenario: simple attribute
    Given a file named "example_spec.rb" with:
      """
      describe Array do
        its(:size) { should == 0 }
      end
      """
    When I run "rspec example_spec.rb --format documentation"
    Then the output should contain:
      """
      Array
        size
          should == 0
      """

  Scenario: nested attribute
    Given a file named "example_spec.rb" with:
      """
      class Person
        attr_reader :phone_numbers
        def initialize
          @phone_numbers = []
        end
      end

      describe Person do
        subject do
          person = Person.new
          person.phone_numbers << "555-1212"
          person
        end

        its("phone_numbers.first") { should == "555-1212" }
      end
      """
    When I run "rspec example_spec.rb --format documentation"
    Then the output should contain:
      """
      Person
        phone_numbers.first
          should == "555-1212"
      """
