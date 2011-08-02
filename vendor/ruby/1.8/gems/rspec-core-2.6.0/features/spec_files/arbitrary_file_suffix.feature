Feature: arbitrary file suffix

  Scenario: .spec
    Given a file named "a.spec" with:
      """
      describe "something" do
        it "does something" do
          3.should eq(3)
        end
      end
      """
    When I run `rspec a.spec`
    Then the examples should all pass
