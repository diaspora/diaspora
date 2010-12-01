Feature: customized message

  In order to get the feedback I want
  As an RSpec user
  I want to customize the failure message per example
  
  Scenario: one additional method
    Given a file named "node_spec.rb" with:
      """
      class Node
        def initialize(state=:waiting)
          @state = state
        end
        def state
          @state
        end
        def waiting?
          @state == :waiting
        end
        def started?
          @state == :started
        end
        def start
          @state = :started
        end
      end

      describe "a new Node" do
        it "should be waiting" do
          node = Node.new(:started) #start w/ started to trigger failure
          node.should be_waiting, "node.state: #{node.state} (first example)"
        end

        it "should not be started" do
          node = Node.new(:started) #start w/ started to trigger failure
          node.should_not be_started, "node.state: #{node.state} (second example)"
        end
      end

      describe "node.start" do
        it "should change the state" do
          node = Node.new(:started) #start w/ started to trigger failure
          lambda {node.start}.should change{node.state}, "expected a change"
        end
      end

      """
    When I run "rspec ./node_spec.rb --format documentation"
    Then the output should contain "3 examples, 3 failures"
    And  the output should not contain "to return true, got false"
    And  the output should not contain "to return false, got true"
    And  the output should contain "node.state: started (first example)"
    And  the output should contain "node.state: started (second example)"
    And  the output should contain "expected a change"
