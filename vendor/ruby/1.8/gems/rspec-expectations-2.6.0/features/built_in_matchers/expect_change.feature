Feature: expect change

  Expect the execution of a block of code to change the state of an object.

  Background:
    Given a file named "lib/counter.rb" with:
      """
      class Counter
        class << self
          def increment
            @count ||= 0
            @count += 1
          end
          
          def count
            @count ||= 0
          end
        end
      end
      """
  
  Scenario: expect change
    Given a file named "spec/example_spec.rb" with:
      """
      require "counter"

      describe Counter, "#increment" do
        it "should increment the count" do
          expect { Counter.increment }.to change{Counter.count}.from(0).to(1)
        end

        # deliberate failure
        it "should increment the count by 2" do
          expect { Counter.increment }.to change{Counter.count}.by(2)
        end
      end
      """
    When I run `rspec spec/example_spec.rb`
    Then the output should contain "1 failure"
    Then the output should contain "should have been changed by 2, but was changed by 1"

  Scenario: expect no change
    Given a file named "spec/example_spec.rb" with:
      """
      require "counter"

      describe Counter, "#increment" do
        it "should not increment the count by 1 (using to_not)" do
          expect { Counter.increment }.to_not change{Counter.count}
        end

        it "should not increment the count by 1 (using not_to)" do
          expect { Counter.increment }.not_to change{Counter.count}
        end
      end
      """
    When I run `rspec spec/example_spec.rb`
    Then the output should contain "2 failures"
    Then the output should contain "should not have changed, but did change from 1 to 2"
