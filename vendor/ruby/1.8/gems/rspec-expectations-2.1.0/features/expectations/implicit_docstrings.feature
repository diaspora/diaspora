Feature: implicit docstrings

  As an RSpec user
  I want examples to generate their own names
  So that I can reduce duplication between example names and example code

  Scenario: run passing examples
    Given a file named "implicit_docstrings_spec.rb" with:
    """
    describe "Examples with no docstrings generate their own:" do

      specify { 3.should be < 5 }

      specify { [1,2,3].should include(2) }

      specify { [1,2,3].should respond_to(:size) }

    end
    """

    When I run "rspec ./implicit_docstrings_spec.rb -fdoc"

    Then the output should contain "should be < 5"
    And the output should contain "should include 2"
    And the output should contain "should respond to #size"

  Scenario: run failing examples
    Given a file named "failing_implicit_docstrings_spec.rb" with:
    """
    describe "Failing examples with no descriptions" do

      # description is auto-generated as "should equal(5)" based on the last #should
      it do
        3.should equal(2)
        5.should equal(5)
      end

      it { 3.should be > 5 }

      it { [1,2,3].should include(4) }

      it { [1,2,3].should_not respond_to(:size) }

    end
    """

    When I run "rspec ./failing_implicit_docstrings_spec.rb -fdoc"

    Then the output should contain "should equal 2"
    And the output should contain "should be > 5"
    And the output should contain "should include 4"
    And the output should contain "should not respond to #size"
