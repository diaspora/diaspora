Feature: attribute of subject

  Use the its() method as a short-hand to generate a nested example group with
  a single example that specifies the expected value of an attribute of the
  subject.  This can be used with an implicit or explicit subject.

  its() accepts a symbol or a string, and a block representing the example.

      its(:size)    { should eq(1) }
      its("length") { should eq(1) }

  You can use a string with dots to specify a nested attribute (i.e. an
  attribute of the attribute of the subject).

      its("phone_numbers.size") { should eq(2) }

  When the subject is a hash, you can pass in an array with a single key to
  access the value at that key in the hash.

      its([:key]) { should eq(value) }

  Scenario: specify value of an attribute
    Given a file named "example_spec.rb" with:
      """
      describe Array do
        context "when first created" do
          its(:size) { should eq(0) }
        end
      end
      """
    When I run `rspec example_spec.rb --format documentation`
    Then the output should contain:
      """
      Array
        when first created
          size
            should == 0
      """

  Scenario: specify value of a nested attribute
    Given a file named "example_spec.rb" with:
      """
      class Person
        attr_reader :phone_numbers
        def initialize
          @phone_numbers = []
        end
      end

      describe Person do
        context "with one phone number (555-1212)"do
          subject do
            person = Person.new
            person.phone_numbers << "555-1212"
            person
          end

          its("phone_numbers.first") { should eq("555-1212") }
        end
      end
      """
    When I run `rspec example_spec.rb --format documentation`
    Then the output should contain:
      """
      Person
        with one phone number (555-1212)
          phone_numbers.first
            should == 555-1212
      """

  Scenario: specify value of an attribute of a hash
    Given a file named "example_spec.rb" with:
      """
      describe Hash do
        context "with two items" do
          subject do
            {:one => 'one', :two => 'two'}
          end

          its(:size) { should eq(2) }
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the examples should all pass

  Scenario: specify value for key in a hash
    Given a file named "example_spec.rb" with:
      """
      describe Hash do
        context "with keys :one and 'two'" do
          subject do
            {:one => 1, "two" => 2}
          end

          its([:one]) { should eq(1) }
          its(["two"]) { should eq(2) }
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the examples should all pass

  Scenario: specify value for key in a hash-like object
    Given a file named "example_spec.rb" with:
      """
      require 'matrix'

      describe Matrix do
        context "with values [[1, 2], [3, 4]]" do
          subject do
            Matrix[[1, 2], [3, 4]]
          end

          its([0, 1]) { should eq(2) }
          its([1, 0]) { should eq(3) }
          its([1, 2]) { should be_nil }
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the examples should all pass
