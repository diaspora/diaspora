Feature: respond_to matcher

  Use the respond_to matcher to specify details of an object's interface.  In
  its most basic form:

    obj.should respond_to(:foo) # pass if obj.respond_to?(:foo)

  You can specify that an object responds to multiple messages in a single
  statement with multiple arguments passed to the matcher:
    
    obj.should respond_to(:foo, :bar) # passes if obj.respond_to?(:foo) && obj.respond_to?(:bar)

  If the number of arguments accepted by the method is important to you,
  you can specify that as well:

    obj.should respond_to(:foo).with(1).argument
    obj.should respond_to(:bar).with(2).arguments

  Note that this matcher relies entirely upon #respond_to?.  If an object
  dynamically responds to a message via #method_missing, but does not indicate
  this via #respond_to?, then this matcher will give you false results.

  Scenario: basic usage
    Given a file named "respond_to_matcher_spec.rb" with:
      """
      describe "a string" do
        it { should respond_to(:length) }
        it { should respond_to(:hash, :class, :to_s) }
        it { should_not respond_to(:to_model) }
        it { should_not respond_to(:compact, :flatten) }

        # deliberate failures
        it { should respond_to(:to_model) }
        it { should respond_to(:compact, :flatten) }
        it { should_not respond_to(:length) }
        it { should_not respond_to(:hash, :class, :to_s) }

        # mixed examples--String responds to :length but not :flatten
        # both specs should fail
        it { should respond_to(:length, :flatten) }
        it { should_not respond_to(:length, :flatten) }
      end
      """
    When I run "rspec respond_to_matcher_spec.rb"
    Then the output should contain all of these:
      | 10 examples, 6 failures                                    |
      | expected "a string" to respond to :to_model                |
      | expected "a string" to respond to :compact, :flatten       |
      | expected "a string" not to respond to :length              |
      | expected "a string" not to respond to :hash, :class, :to_s |
      | expected "a string" to respond to :flatten                 |
      | expected "a string" not to respond to :length              |

  Scenario: specify arguments
    Given a file named "respond_to_matcher_argument_checking_spec.rb" with:
      """
      describe 7 do
        it { should respond_to(:zero?).with(0).arguments }
        it { should_not respond_to(:zero?).with(1).argument }

        it { should respond_to(:between?).with(2).arguments }
        it { should_not respond_to(:between?).with(7).arguments }

        # deliberate failures
        it { should respond_to(:zero?).with(1).argument }
        it { should_not respond_to(:zero?).with(0).arguments }

        it { should respond_to(:between?).with(7).arguments }
        it { should_not respond_to(:between?).with(2).arguments }
      end
      """
    When I run "rspec respond_to_matcher_argument_checking_spec.rb"
    Then the output should contain all of these:
      | 8 examples, 4 failures                                  |
      | expected 7 to respond to :zero? with 1 argument         |
      | expected 7 not to respond to :zero? with 0 arguments    |
      | expected 7 to respond to :between? with 7 arguments     |
      | expected 7 not to respond to :between? with 2 arguments |
