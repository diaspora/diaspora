Feature: current example

  You can reference the example object, and access its metadata, using
  the `example` method within an example.

  Scenario: access the example object from within an example
    Given a file named "spec/example_spec.rb" with:
      """
      describe "an example" do
        it "knows itself as example" do
          example.description.should eq("knows itself as example")
        end
      end
      """
    When I run `rspec spec/example_spec.rb`
    Then the example should pass

