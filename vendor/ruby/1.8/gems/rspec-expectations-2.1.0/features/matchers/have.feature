Feature: have(n).items matcher

  RSpec provides several matchers that make it easy to set expectations about the
  size of a collection.  There are three basic forms:

    * collection.should have(x).items
    * collection.should have_at_least(x).items
    * collection.should have_at_most(x).items

  In addition, #have_exactly is provided as an alias to #have.

  These work on any collection-like object--the object just needs to respond to #size
  or #length (or both).  When the matcher is called directly on a collection object,
  the #items call is pure syntactic sugar.  You can use anything you want here.  These
  are equivalent:

    * collection.should have(x).items
    * collection.should have(x).things

  You can also use this matcher on a non-collection object that returns a collection
  from one of its methods.  For example, Dir#entries returns an array, so you could
  set an expectation using the following:

    Dir.new("my/directory").should have(7).entries

  Scenario: have(x).items on a collection
    Given a file named "have_items_spec.rb" with:
      """
      describe [1, 2, 3] do
        it { should have(3).items }
        it { should_not have(2).items }
        it { should_not have(4).items }

        it { should have_exactly(3).items }
        it { should_not have_exactly(2).items }
        it { should_not have_exactly(4).items }

        it { should have_at_least(2).items }
        it { should have_at_most(4).items }

        # deliberate failures
        it { should_not have(3).items }
        it { should have(2).items }
        it { should have(4).items }

        it { should_not have_exactly(3).items }
        it { should have_exactly(2).items }
        it { should have_exactly(4).items }

        it { should have_at_least(4).items }
        it { should have_at_most(2).items }
      end
      """
     When I run "rspec have_items_spec.rb"
     Then the output should contain "16 examples, 8 failures"
      And the output should contain "expected target not to have 3 items, got 3"
      And the output should contain "expected 2 items, got 3"
      And the output should contain "expected 4 items, got 3"
      And the output should contain "expected at least 4 items, got 3"
      And the output should contain "expected at most 2 items, got 3"

  Scenario: have(x).words on a String when String#words is defined
    Given a file named "have_words_spec.rb" with:
      """
      class String
        def words
          split(' ')
        end
      end

      describe "a sentence with some words" do
        it { should have(5).words }
        it { should_not have(4).words }
        it { should_not have(6).words }

        it { should have_exactly(5).words }
        it { should_not have_exactly(4).words }
        it { should_not have_exactly(6).words }

        it { should have_at_least(4).words }
        it { should have_at_most(6).words }

        # deliberate failures
        it { should_not have(5).words }
        it { should have(4).words }
        it { should have(6).words }

        it { should_not have_exactly(5).words }
        it { should have_exactly(4).words }
        it { should have_exactly(6).words }

        it { should have_at_least(6).words }
        it { should have_at_most(4).words }
      end
      """
     When I run "rspec have_words_spec.rb"
     Then the output should contain "16 examples, 8 failures"
      And the output should contain "expected target not to have 5 words, got 5"
      And the output should contain "expected 4 words, got 5"
      And the output should contain "expected 6 words, got 5"
      And the output should contain "expected at least 6 words, got 5"
      And the output should contain "expected at most 4 words, got 5"

