Feature: include matcher

  Use the include matcher to specify that a collection includes one or more
  expected objects.  This works on any object that responds to #include?  (such
  as a string or array):

    "a string".should include("a")
    "a string".should include("str")
    "a string".should include("str", "g")
    "a string".should_not include("foo")

    [1, 2].should include(1)
    [1, 2].should include(1, 2)
    [1, 2].should_not include(17)

  The matcher also provides flexible handling for hashes:

    {:a => 1, :b => 2}.should include(:a)
    {:a => 1, :b => 2}.should include(:a, :b)
    {:a => 1, :b => 2}.should include(:a => 1)
    {:a => 1, :b => 2}.should include(:b => 2, :a => 1)
    {:a => 1, :b => 2}.should_not include(:c)
    {:a => 1, :b => 2}.should_not include(:a => 2)
    {:a => 1, :b => 2}.should_not include(:c => 3)

  Scenario: array usage
    Given a file named "array_include_matcher_spec.rb" with:
      """
      describe [1, 3, 7] do
        it { should include(1) }
        it { should include(3) }
        it { should include(7) }
        it { should include(1, 7) }
        it { should include(1, 3, 7) }
        it { should_not include(17) }
        it { should_not include(43, 100) }

        # deliberate failures
        it { should include(4) }
        it { should_not include(1) }
        it { should_not include(3) }
        it { should_not include(7) }
        it { should_not include(1, 3, 7) }

        # both of these should fail since it includes 1 but not 9
        it { should include(1, 9) }
        it { should_not include(1, 9) }
      end
      """
    When I run `rspec array_include_matcher_spec.rb`
    Then the output should contain all of these:
      | 14 examples, 7 failures                       |
      | expected [1, 3, 7] to include 4               |
      | expected [1, 3, 7] not to include 1           |
      | expected [1, 3, 7] not to include 3           |
      | expected [1, 3, 7] not to include 7           |
      | expected [1, 3, 7] not to include 1, 3, and 7 |
      | expected [1, 3, 7] to include 1 and 9         |
      | expected [1, 3, 7] not to include 1 and 9     |

  Scenario: string usage
    Given a file named "string_include_matcher_spec.rb" with:
      """
      describe "a string" do
        it { should include("str") }
        it { should include("a", "str", "ng") }
        it { should_not include("foo") }
        it { should_not include("foo", "bar") }

        # deliberate failures
        it { should include("foo") }
        it { should_not include("str") }
        it { should include("str", "foo") }
        it { should_not include("str", "foo") }
      end
      """
    When I run `rspec string_include_matcher_spec.rb`
    Then the output should contain all of these:
      | 8 examples, 4 failures                             |
      | expected "a string" to include "foo"               |
      | expected "a string" not to include "str"           |
      | expected "a string" to include "str" and "foo"     |
      | expected "a string" not to include "str" and "foo" |

  Scenario: hash usage
    Given a file named "hash_include_matcher_spec.rb" with:
      """
      describe Hash do
        subject { { :a => 7, :b => 5 } }

        it { should include(:a) }
        it { should include(:b, :a) }
        it { should include(:a => 7) }
        it { should include(:b => 5, :a => 7) }
        it { should_not include(:c) }
        it { should_not include(:c, :d) }
        it { should_not include(:d => 2) }
        it { should_not include(:a => 5) }
        it { should_not include(:b => 7, :a => 5) }

        # deliberate failures
        it { should_not include(:a) }
        it { should_not include(:b, :a) }
        it { should_not include(:a => 7) }
        it { should_not include(:a => 7, :b => 5) }
        it { should include(:c) }
        it { should include(:c, :d) }
        it { should include(:d => 2) }
        it { should include(:a => 5) }
        it { should include(:a => 5, :b => 7) }

        # Mixed cases--the hash includes one but not the other.
        # All 4 of these cases should fail.
        it { should include(:a, :d) }
        it { should_not include(:a, :d) }
        it { should include(:a => 7, :d => 3) }
        it { should_not include(:a => 7, :d => 3) }
      end
      """
    When I run `rspec hash_include_matcher_spec.rb`
    Then the output should contain "13 failure"
