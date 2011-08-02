@ruby-1.9
Feature: cover matcher

  Use the cover matcher to specify that a range covers one or more
  expected objects.  This works on any object that responds to #cover?  (such
  as a Range):

    (1..10).should cover(5)
    (1..10).should cover(4, 6)
    (1..10).should_not cover(11)

  Scenario: range usage
    Given a file named "range_cover_matcher_spec.rb" with:
      """
      describe (1..10) do
        it { should cover(4) }
        it { should cover(6) }
        it { should cover(8) }
        it { should cover(4, 6) }
        it { should cover(4, 6, 8) }
        it { should_not cover(11) }
        it { should_not cover(11, 12) }

        # deliberate failures
        it { should cover(11) }
        it { should_not cover(4) }
        it { should_not cover(6) }
        it { should_not cover(8) }
        it { should_not cover(4, 6, 8) }

        # both of these should fail since it covers 1 but not 9
        it { should cover(5, 11) }
        it { should_not cover(5, 11) }
      end
      """
    When I run `rspec range_cover_matcher_spec.rb`
    Then the output should contain all of these:
      | 14 examples, 7 failures                 |
      | expected 1..10 to cover 11              |
      | expected 1..10 not to cover 4           |
      | expected 1..10 not to cover 6           |
      | expected 1..10 not to cover 8           |
      | expected 1..10 not to cover 4, 6, and 8 |
      | expected 1..10 to cover 5 and 11        |
      | expected 1..10 not to cover 5 and 11    |
