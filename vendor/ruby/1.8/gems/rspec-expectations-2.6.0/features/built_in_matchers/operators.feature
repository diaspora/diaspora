Feature: operator matchers

  RSpec provides a number of matchers that are based on Ruby's built-in
  operators. These pretty much work like you expect. For example, each of these
  pass:

      7.should == 7
      [1, 2, 3].should == [1, 2, 3]
      "this is a string".should =~ /^this/
      "this is a string".should_not =~ /^that/
      String.should === "this is a string"

  You can also use comparison operators combined with the "be" matcher like
  this:

      37.should be < 100
      37.should be <= 38
      37.should be >= 2
      37.should be > 7

  RSpec also provides a `=~` matcher for arrays that disregards differences in
  the ording between the actual and expected array.  For example:

      [1, 2, 3].should =~ [2, 3, 1] # pass
      [:a, :c, :b].should =~ [:a, :c] # fail

  Scenario: numeric operator matchers
    Given a file named "numeric_operator_matchers_spec.rb" with:
      """
      describe 18 do
        it { should == 18 }
        it { should be < 20 }
        it { should be > 15 }
        it { should be <= 19 }
        it { should be >= 17 }

        it { should_not == 28 }

        # deliberate failures
        it { should == 28 }
        it { should be < 15 }
        it { should be > 20 }
        it { should be <= 17 }
        it { should be >= 19 }

        it { should_not == 18 }
      end
      """
     When I run `rspec numeric_operator_matchers_spec.rb`
     Then the output should contain "12 examples, 6 failures"
      And the output should contain:
      """
           Failure/Error: it { should == 28 }
             expected: 28
                  got: 18 (using ==)
      """
      And the output should contain:
      """
           Failure/Error: it { should be < 15 }
             expected: < 15
                  got:   18
      """
      And the output should contain:
      """
           Failure/Error: it { should be > 20 }
             expected: > 20
                  got:   18
      """
      And the output should contain:
      """
           Failure/Error: it { should be <= 17 }
             expected: <= 17
                  got:    18
      """
      And the output should contain:
      """
           Failure/Error: it { should be >= 19 }
             expected: >= 19
                  got:    18
      """
      And the output should contain:
      """
           Failure/Error: it { should_not == 18 }
             expected not: == 18
                      got:    18
      """

  Scenario: string operator matchers
    Given a file named "string_operator_matchers_spec.rb" with:
      """
      describe "Strawberry" do
        it { should == "Strawberry" }
        it { should be < "Tomato" }
        it { should be > "Apple" }
        it { should be <= "Turnip" }
        it { should be >= "Banana" }
        it { should =~ /berry/ }

        it { should_not == "Peach" }
        it { should_not =~ /apple/ }

        it "reports that it is a string using ===" do
          String.should === subject
        end

        # deliberate failures
        it { should == "Peach" }
        it { should be < "Cranberry" }
        it { should be > "Zuchini" }
        it { should be <= "Potato" }
        it { should be >= "Tomato" }
        it { should =~ /apple/ }

        it { should_not == "Strawberry" }
        it { should_not =~ /berry/ }

        it "fails a spec asserting that it is a symbol" do
          Symbol.should === subject
        end
      end
      """
     When I run `rspec string_operator_matchers_spec.rb`
     Then the output should contain "18 examples, 9 failures"
      And the output should contain:
      """
           Failure/Error: it { should == "Peach" }
             expected: "Peach"
                  got: "Strawberry" (using ==)
      """
      And the output should contain:
      """
           Failure/Error: it { should be < "Cranberry" }
             expected: < "Cranberry"
                  got:   "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should be > "Zuchini" }
             expected: > "Zuchini"
                  got:   "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should be <= "Potato" }
             expected: <= "Potato"
                  got:    "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should be >= "Tomato" }
             expected: >= "Tomato"
                  got:    "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should =~ /apple/ }
             expected: /apple/
                  got: "Strawberry" (using =~)
      """
      And the output should contain:
      """
           Failure/Error: it { should_not == "Strawberry" }
             expected not: == "Strawberry"
                      got:    "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should_not =~ /berry/ }
             expected not: =~ /berry/
                      got:    "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: Symbol.should === subject
             expected: "Strawberry"
                  got: Symbol (using ===)
      """

  Scenario: array operator matchers
    Given a file named "array_operator_matchers_spec.rb" with:
      """
      describe [1, 2, 3] do
        it { should == [1, 2, 3] }
        it { should_not == [1, 3, 2] }

        it { should =~ [1, 2, 3] }
        it { should =~ [1, 3, 2] }
        it { should =~ [2, 1, 3] }
        it { should =~ [2, 3, 1] }
        it { should =~ [3, 1, 2] }
        it { should =~ [3, 2, 1] }

        # deliberate failures
        it { should_not == [1, 2, 3] }
        it { should == [1, 3, 2] }
        it { should =~ [1, 2, 1] }
      end
      """
     When I run `rspec array_operator_matchers_spec.rb`
     Then the output should contain "11 examples, 3 failures"
      And the output should contain:
      """
           Failure/Error: it { should_not == [1, 2, 3] }
             expected not: == [1, 2, 3]
                      got:    [1, 2, 3]
      """
      And the output should contain:
      """
           Failure/Error: it { should == [1, 3, 2] }
             expected: [1, 3, 2]
                  got: [1, 2, 3] (using ==)
      """
      And the output should contain:
      """
           Failure/Error: it { should =~ [1, 2, 1] }
             expected collection contained:  [1, 1, 2]
             actual collection contained:    [1, 2, 3]
             the missing elements were:      [1]
             the extra elements were:        [3]
      """

