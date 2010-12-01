Feature: Equality matchers

  Ruby exposes several different methods for handling equality:

    a.equal?(b) # object identity - a and b refer to the same object
    a.eql?(b)   # object equivalence - a and b have the same value
    a == b      # object equivalence - a and b have the same value with type conversions

  Note that these descriptions are guidelines but are not forced by the
  language. Any object can implement any of these methods with its own
  semantics.

  rspec-expectations ships with matchers that align with each of these methods:

    a.should equal(b) # passes if a.equal?(b)
    a.should eql(b)   # passes if a.eql?(b)
    a.should == b     # passes if a == b

  It also ships with two matchers that have more of a DSL feel to them:

    a.should be(b) # passes if a.equal?(b)
    a.should eq(b) # passes if a == b

  Scenario: compare using eq (==)
    Given a file named "compare_using_eq.rb" with:
      """
      require 'spec_helper'

      describe "a string" do
        it "is equal to another string of the same value" do
          "this string".should eq("this string")
        end

        it "is not equal to another string of a different value" do
          "this string".should_not eq("a different string")
        end
      end

      describe "an integer" do
        it "is equal to a float of the same value" do
          5.should eq(5.0)
        end
      end
      """
    When I run "rspec compare_using_eq.rb"
    Then the output should contain "3 examples, 0 failures"

  Scenario: compare using ==
    Given a file named "compare_using_==.rb" with:
      """
      require 'spec_helper'

      describe "a string" do
        it "is equal to another string of the same value" do
          "this string".should == "this string"
        end

        it "is not equal to another string of a different value" do
          "this string".should_not == "a different string"
        end
      end

      describe "an integer" do
        it "is equal to a float of the same value" do
          5.should == 5.0
        end
      end
      """
    When I run "rspec compare_using_==.rb"
    Then the output should contain "3 examples, 0 failures"

  Scenario: compare using eql (eql?)
    Given a file named "compare_using_eql.rb" with:
      """
      require 'spec_helper'

      describe "an integer" do
        it "is equal to another integer of the same value" do
          5.should eql(5)
        end

        it "is not equal to another integer of a different value" do
          5.should_not eql(6)
        end

        it "is not equal to a float of the same value" do
          5.should_not eql(5.0)
        end

      end
      """
    When I run "rspec compare_using_eql.rb"
    Then the output should contain "3 examples, 0 failures"

  Scenario: compare using equal (equal?)
    Given a file named "compare_using_equal.rb" with:
      """
      require 'spec_helper'

      describe "a string" do
        it "is equal to itself" do
          string = "this string"
          string.should equal(string)
        end

        it "is not equal to another string of the same value" do
          "this string".should_not equal("this string")
        end

        it "is not equal to another string of a different value" do
          "this string".should_not equal("a different string")
        end

      end
      """
    When I run "rspec compare_using_equal.rb"
    Then the output should contain "3 examples, 0 failures"

  Scenario: compare using be (equal?)
    Given a file named "compare_using_be.rb" with:
      """
      require 'spec_helper'

      describe "a string" do
        it "is equal to itself" do
          string = "this string"
          string.should be(string)
        end

        it "is not equal to another string of the same value" do
          "this string".should_not be("this string")
        end

        it "is not equal to another string of a different value" do
          "this string".should_not be("a different string")
        end

      end
      """
    When I run "rspec compare_using_be.rb"
    Then the output should contain "3 examples, 0 failures"

