Feature: satisfy matcher

  The satisfy matcher is extremely flexible and can handle almost anything
  you want to specify.  It passes if the block you provide returns true:

    10.should satisfy { |v| v % 5 == 0 }
    7.should_not satisfy { |v| v % 5 == 0 }

  This flexibility comes at a cost, however: the failure message
  ("expected [actual] to satisfy block") is not very descriptive
  or helpful.  You will usually be better served by using one of
  the other built-in matchers, or writing a custom matcher.

  Scenario: basic usage
    Given a file named "satisfy_matcher_spec.rb" with:
      """
      describe 10 do
        it { should satisfy { |v| v > 5 } }
        it { should_not satisfy { |v| v > 15 } }

        # deliberate failures
        it { should_not satisfy { |v| v > 5 } }
        it { should satisfy { |v| v > 15 } }
      end
      """
    When I run `rspec satisfy_matcher_spec.rb`
    Then the output should contain all of these:
      | 4 examples, 2 failures           |
      | expected 10 not to satisfy block |
      | expected 10 to satisfy block     |

