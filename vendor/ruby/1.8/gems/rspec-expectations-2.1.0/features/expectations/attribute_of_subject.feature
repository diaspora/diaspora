Feature: attribute of subject

  In order to get more meaningful failure messages
  As a spec author
  I want RSpec to tell me what attribute a matcher applies
    to when using the its(:attribute) technique

  Scenario: eq matcher fails
    Given a file named "example_spec.rb" with:
    """
    describe "an array" do
      subject { [] }
      its(:size) { should eq(1) } # intentionally fail
    end
    """

    When I run "rspec example_spec.rb -fdoc"
    Then the output should contain "Failure/Error: its(:size) { should eq(1) }"
    And  the output should contain "expected 1"
