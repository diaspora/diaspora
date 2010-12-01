Feature: pending examples

  RSpec offers four ways to indicate that an example is disabled pending
  some action.

  Scenario: pending implementation
    Given a file named "example_without_block_spec.rb" with:
      """
      describe "an example" do
        it "is a pending example"
      end
      """
    When I run "rspec example_without_block_spec.rb"
    Then the exit status should be 0
    And the output should contain "1 example, 0 failures, 1 pending"
    And the output should contain "Not Yet Implemented"
    And the output should contain "example_without_block_spec.rb:2"

  Scenario: pending any arbitary reason, with no block
    Given a file named "pending_without_block_spec.rb" with:
      """
      describe "an example" do
        it "is implemented but waiting" do
          pending("something else getting finished")
          this_should_not_get_executed
        end
      end
      """
    When I run "rspec pending_without_block_spec.rb"
    Then the exit status should be 0
    And the output should contain "1 example, 0 failures, 1 pending"
    And the output should contain:
      """
      Pending:
        an example is implemented but waiting
          # something else getting finished
          # ./pending_without_block_spec.rb:2
      """

  Scenario: pending any arbitary reason, with a block that fails
    Given a file named "pending_with_failing_block_spec.rb" with:
      """
      describe "an example" do
        it "is implemented but waiting" do
          pending("something else getting finished") do
            raise "this is the failure"
          end
        end
      end
      """
    When I run "rspec pending_with_failing_block_spec.rb"
    Then the exit status should be 0
    And the output should contain "1 example, 0 failures, 1 pending"
    And the output should contain:
      """
      Pending:
        an example is implemented but waiting
          # something else getting finished
          # ./pending_with_failing_block_spec.rb:2
      """

  Scenario: pending any arbitary reason, with a block that passes
    Given a file named "pending_with_passing_block_spec.rb" with:
      """
      describe "an example" do
        it "is implemented but waiting" do
          pending("something else getting finished") do
            true.should be(true)
          end
        end
      end
      """
    When I run "rspec pending_with_passing_block_spec.rb"
    Then the exit status should not be 0
    And the output should contain "1 example, 1 failure"
    And the output should contain "FIXED"
    And the output should contain "Expected pending 'something else getting finished' to fail. No Error was raised."
    And the output should contain "pending_with_passing_block_spec.rb:3"

  Scenario: temporarily pending by changing "it" to "xit"
    Given a file named "pending_with_xit_spec.rb" with:
      """
      describe "an example" do
        xit "is pending using xit" do
          true.should be(true)
        end
      end
      """
    When I run "rspec pending_with_xit_spec.rb"
    Then the exit status should be 0
    And the output should contain "1 example, 0 failures, 1 pending"
    And the output should contain:
      """
      Pending:
        an example is pending using xit
      """

  Scenario: example with no docstring and pending method using documentation formatter
    Given a file named "pending_with_no_docstring_spec.rb" with:
      """
      describe "an example" do
        it "checks something" do
          (3+4).should == 7
        end
        specify do
          pending
        end
      end
      """
    When I run "rspec pending_with_no_docstring_spec.rb --format documentation"
    Then the exit status should be 0
    And the output should contain "2 examples, 0 failures, 1 pending"
    And the output should contain:
      """
      an example
        checks something
         (PENDING: No reason given)
      """

  Scenario: pending with no docstring using documentation formatter
    Given a file named "pending_with_no_docstring_spec.rb" with:
      """
      describe "an example" do
        it "checks something" do
          (3+4).should == 7
        end
        pending do
          "string".reverse.should == "gnirts"
        end
      end
      """
    When I run "rspec pending_with_no_docstring_spec.rb --format documentation"
    Then the exit status should be 0
    And the output should contain "2 examples, 0 failures, 1 pending"
    And the output should contain:
      """
      an example
        checks something
         (PENDING: Not Yet Implemented)
      """

  Scenario: conditionally pending examples
    Given a file named "conditionally_pending_spec.rb" with:
      """
      describe "a failing spec" do
        def run_test; raise "failure"; end

        it "is pending when pending with a true :if condition" do
          pending("true :if", :if => true) { run_test }
        end

        it "fails when pending with a false :if condition" do
          pending("false :if", :if => false) { run_test }
        end

        it "is pending when pending with a false :unless condition" do
          pending("false :unless", :unless => false) { run_test }
        end

        it "fails when pending with a true :unless condition" do
          pending("true :unless", :unless => true) { run_test }
        end
      end

      describe "a passing spec" do
        def run_test; true.should be(true); end

        it "fails when pending with a true :if condition" do
          pending("true :if", :if => true) { run_test }
        end

        it "passes when pending with a false :if condition" do
          pending("false :if", :if => false) { run_test }
        end

        it "fails when pending with a false :unless condition" do
          pending("false :unless", :unless => false) { run_test }
        end

        it "passes when pending with a true :unless condition" do
          pending("true :unless", :unless => true) { run_test }
        end
      end
      """
    When I run "rspec ./conditionally_pending_spec.rb"
    Then the output should contain "8 examples, 4 failures, 2 pending"
    And the output should contain:
      """
      Pending:
        a failing spec is pending when pending with a true :if condition
          # true :if
          # ./conditionally_pending_spec.rb:4
        a failing spec is pending when pending with a false :unless condition
          # false :unless
          # ./conditionally_pending_spec.rb:12
      """
    And the output should contain:
      """
        1) a failing spec fails when pending with a false :if condition
           Failure/Error: def run_test; raise "failure"; end
      """
    And the output should contain:
      """
        2) a failing spec fails when pending with a true :unless condition
           Failure/Error: def run_test; raise "failure"; end
      """
    And the output should contain:
      """
        3) a passing spec fails when pending with a true :if condition FIXED
           Expected pending 'true :if' to fail. No Error was raised.
      """
    And the output should contain:
      """
        4) a passing spec fails when pending with a false :unless condition FIXED
           Expected pending 'false :unless' to fail. No Error was raised.
      """
