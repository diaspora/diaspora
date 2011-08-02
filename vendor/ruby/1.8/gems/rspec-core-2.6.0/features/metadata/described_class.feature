Feature: described class

  If the first argument to the outermost example group is a class, the class is
  exposed to each example via the described_class() method.

  Scenario: access the described class from the example
    Given a file named "spec/example_spec.rb" with:
      """
      describe Fixnum do
        it "is available as described_class" do
          described_class.should eq(Fixnum)
        end
      end
      """
    When I run `rspec spec/example_spec.rb`
    Then the example should pass

