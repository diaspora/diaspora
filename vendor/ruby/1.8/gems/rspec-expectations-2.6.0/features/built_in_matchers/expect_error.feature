Feature: raise_error matcher

  Use the `raise_error` matcher to specify that a block of code raises an
  error. The most basic form passes if any error is thrown:

      expect { raise StandardError }.to raise_error

  You can use `raise_exception` instead if you prefer that wording:

      expect { 3 / 0 }.to raise_exception

  `raise_error` and `raise_exception` are functionally interchangeable, so use
  the one that makes the most sense to you in any given context.

  In addition to the basic form, above, there are a number of ways to specify
  details of an error/exception:

  Scenario: expect any error
    Given a file named "expect_error_spec.rb" with:
      """
      describe "calling a method that does not exist" do
        it "raises" do
          expect { Object.new.foo }.to raise_error
        end
      end
      """
    When I run `rspec expect_error_spec.rb`
    Then the example should pass

  Scenario: expect specific error
    Given a file named "expect_error_spec.rb" with:
      """
      describe "calling a method that does not exist" do
        it "raises" do
          expect { Object.new.foo }.to raise_error(NameError)
        end
      end
      """
    When I run `rspec expect_error_spec.rb`
    Then the example should pass

  Scenario: expect specific error message using a string
    Given a file named "expect_error_with_message.rb" with:
      """
      describe "matching error message with string" do
        it "matches the error message" do
          expect { raise StandardError, 'this message exactly'}.
            to raise_error(StandardError, 'this message exactly')
        end
      end
      """
    When I run `rspec expect_error_with_message.rb`
    Then the example should pass

  Scenario: expect specific error message using a regular expression
    Given a file named "expect_error_with_regex.rb" with:
      """
      describe "matching error message with regex" do
        it "matches the error message" do
          expect { raise StandardError, "my message" }.
            to raise_error(StandardError, /my mess/)
        end
      end
      """
    When I run `rspec expect_error_with_regex.rb`
    Then the example should pass

  Scenario: set expectations on error object passed to block
    Given a file named "expect_error_with_block_spec.rb" with:
      """
      describe "#foo" do
        it "raises NameError" do
          expect { Object.new.foo }.to raise_error { |error|
            error.should be_a(NameError)
          }
        end
      end
      """
      When I run `rspec expect_error_with_block_spec.rb`
      Then the example should pass

  Scenario: expect no error at all
    Given a file named "expect_no_error_spec.rb" with:
      """
      describe "#to_s" do
        it "does not raise" do
          expect { Object.new.to_s }.to_not raise_error
        end
      end
      """
    When I run `rspec expect_no_error_spec.rb`
    Then the example should pass
    
  Scenario: expect no occurence of a specific error
    Given a file named "expect_no_error_spec.rb" with:
      """
      describe Object, "#public_instance_methods" do
        it "does not raise" do
          expect { Object.public_instance_methods }.
            to_not raise_error(NameError)
        end
      end
      """
    When I run `rspec expect_no_error_spec.rb`
    Then the example should pass
