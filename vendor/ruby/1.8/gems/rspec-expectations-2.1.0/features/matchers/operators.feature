Feature: Operator matchers

  RSpec provides a number of matchers that are based on Ruby's built-in
  operators.  These mostly work like you expect.  For example, each of these pass:

    * 7.should == 7
    * 25.2.should < 100
    * 8.should > 7
    * 17.should <= 17
    * 3.should >= 2
    * [1, 2, 3].should == [1, 2, 3]
    * "this is a string".should =~ /^this/
    * "this is a string".should_not =~ /^that/
    * String.should === "this is a string"

  RSpec also provides a `=~` matcher for arrays that disregards differences in
  the ording between the actual and expected array.  For example:

    * [1, 2, 3].should =~ [2, 3, 1] # pass
    * [:a, :c, :b].should =~ [:a, :c] # fail

  Scenario: numeric operator matchers
    Given a file named "numeric_operator_matchers_spec.rb" with:
      """
      describe 18 do
        it { should == 18 }
        it { should < 20 }
        it { should > 15 }
        it { should <= 19 }
        it { should >= 17 }

        it { should_not == 28 }
        it { should_not < 15 }
        it { should_not > 20 }
        it { should_not <= 17 }
        it { should_not >= 19 }

        # deliberate failures
        it { should == 28 }
        it { should < 15 }
        it { should > 20 }
        it { should <= 17 }
        it { should >= 19 }

        it { should_not == 18 }
        it { should_not < 20 }
        it { should_not > 15 }
        it { should_not <= 19 }
        it { should_not >= 17 }
      end
      """
     When I run "rspec numeric_operator_matchers_spec.rb"
     Then the output should contain "20 examples, 10 failures"
      And the output should contain:
      """
           Failure/Error: it { should == 28 }
           expected: 28,
                got: 18 (using ==)
      """
      And the output should contain:
      """
           Failure/Error: it { should < 15 }
           expected: < 15,
                got:   18
      """
      And the output should contain:
      """
           Failure/Error: it { should > 20 }
           expected: > 20,
                got:   18
      """
      And the output should contain:
      """
           Failure/Error: it { should <= 17 }
           expected: <= 17,
                got:    18
      """
      And the output should contain:
      """
           Failure/Error: it { should >= 19 }
           expected: >= 19,
                got:    18
      """
      And the output should contain:
      """
           Failure/Error: it { should_not == 18 }
           expected not: == 18,
                    got:    18
      """
      And the output should contain:
      """
           Failure/Error: it { should_not < 20 }
           expected not: < 20,
                    got:   18
      """
      And the output should contain:
      """
           Failure/Error: it { should_not > 15 }
           expected not: > 15,
                    got:   18
      """
      And the output should contain:
      """
           Failure/Error: it { should_not <= 19 }
           expected not: <= 19,
                    got:    18
      """
      And the output should contain:
      """
           Failure/Error: it { should_not >= 17 }
           expected not: >= 17,
                    got:    18
      """

  Scenario: string operator matchers
    Given a file named "string_operator_matchers_spec.rb" with:
      """
      describe "Strawberry" do
        it { should == "Strawberry" }
        it { should < "Tomato" }
        it { should > "Apple" }
        it { should <= "Turnip" }
        it { should >= "Banana" }
        it { should =~ /berry/ }

        it { should_not == "Peach" }
        it { should_not < "Cranberry" }
        it { should_not > "Zuchini" }
        it { should_not <= "Potato" }
        it { should_not >= "Tomato" }
        it { should_not =~ /apple/ }

        it "reports that it is a string using ===" do
          String.should === subject
        end

        # deliberate failures
        it { should == "Peach" }
        it { should < "Cranberry" }
        it { should > "Zuchini" }
        it { should <= "Potato" }
        it { should >= "Tomato" }
        it { should =~ /apple/ }

        it { should_not == "Strawberry" }
        it { should_not < "Tomato" }
        it { should_not > "Apple" }
        it { should_not <= "Turnip" }
        it { should_not >= "Banana" }
        it { should_not =~ /berry/ }

        it "fails a spec asserting that it is a symbol" do
          Symbol.should === subject
        end
      end
      """
     When I run "rspec string_operator_matchers_spec.rb"
     Then the output should contain "26 examples, 13 failures"
      And the output should contain:
      """
           Failure/Error: it { should == "Peach" }
           expected: "Peach",
                got: "Strawberry" (using ==)
      """
      And the output should contain:
      """
           Failure/Error: it { should < "Cranberry" }
           expected: < "Cranberry",
                got:   "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should > "Zuchini" }
           expected: > "Zuchini",
                got:   "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should <= "Potato" }
           expected: <= "Potato",
                got:    "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should >= "Tomato" }
           expected: >= "Tomato",
                got:    "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should =~ /apple/ }
           expected: /apple/,
                got: "Strawberry" (using =~)
      """
      And the output should contain:
      """
           Failure/Error: it { should_not == "Strawberry" }
           expected not: == "Strawberry",
                    got:    "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should_not < "Tomato" }
           expected not: < "Tomato",
                    got:   "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should_not > "Apple" }
           expected not: > "Apple",
                    got:   "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should_not <= "Turnip" }
           expected not: <= "Turnip",
                    got:    "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should_not >= "Banana" }
           expected not: >= "Banana",
                    got:    "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: it { should_not =~ /berry/ }
           expected not: =~ /berry/,
                    got:    "Strawberry"
      """
      And the output should contain:
      """
           Failure/Error: Symbol.should === subject
           expected: "Strawberry",
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
     When I run "rspec array_operator_matchers_spec.rb"
     Then the output should contain "11 examples, 3 failures"
      And the output should contain:
      """
           Failure/Error: it { should_not == [1, 2, 3] }
           expected not: == [1, 2, 3],
                    got:    [1, 2, 3]
      """
      And the output should contain:
      """
           Failure/Error: it { should == [1, 3, 2] }
           expected: [1, 3, 2],
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

