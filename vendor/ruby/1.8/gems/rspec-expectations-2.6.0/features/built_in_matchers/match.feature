Feature: match matcher

  The match matcher calls #match on the object, passing if #match returns a
  truthy (not false or nil) value.  Regexp and String both provide a #match
  method.

    "a string".should match(/str/) # passes
    "a string".should match(/foo/) # fails
    /foo/.should match("food")     # passes
    /foo/.should match("drinks")   # fails

  This is equivalent to using the =~ matcher (see the operator matchers
  feature for more details).

  Scenario: string usage
    Given a file named "string_match_spec.rb" with:
      """
      describe "a string" do
        it { should match(/str/) }
        it { should_not match(/foo/) }

        # deliberate failures
        it { should_not match(/str/) }
        it { should match(/foo/) }
      end
      """
    When I run `rspec string_match_spec.rb`
    Then the output should contain all of these:
      | 4 examples, 2 failures                 |
      | expected "a string" not to match /str/ |
      | expected "a string" to match /foo/     |

  Scenario: regular expression usage
    Given a file named "regexp_match_spec.rb" with:
      """
      describe /foo/ do
        it { should match("food") }
        it { should_not match("drinks") }

        # deliberate failures
        it { should_not match("food") }
        it { should match("drinks") }
      end
      """
    When I run `rspec regexp_match_spec.rb`
    Then the output should contain all of these:
      | 4 examples, 2 failures             |
      | expected /foo/ not to match "food" |
      | expected /foo/ to match "drinks"   |

