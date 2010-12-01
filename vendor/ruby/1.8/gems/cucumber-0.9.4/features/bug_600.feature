Feature: http://rspec.lighthouseapp.com/projects/16211/tickets/600-inconsistent-order-of-execution-background-and-before-in-070beta2

  Scenario: Background executed twice when scenario follows scenario outline
    Given a standard Cucumber project directory structure
    And a file named "features/t.feature" with:
      """
      Feature: test
        Background: 
          Given I am in the background

        Scenario Outline: test 1
          Given I am a step

          Examples:
            | a |
            | 1 |

        Scenario: test 2
      """
    And a file named "features/step_definitions/t_steps.rb" with:
      """
      Given "I am in the background" do
        puts "Within background"
      end

      Given "I am a step" do
        # no-op
      end
      """
    And a file named "features/support/env.rb" with:
      """
      module TestWorld
        def before_scenario
          puts "Before scenario"
        end

        def after_scenario
          puts "After scenario"
        end
      end

      World(TestWorld)

      Before do
        before_scenario
      end

      After do
        after_scenario
      end
      """
    When I run cucumber -f progress features/t.feature
    Then it should pass with
      """
      Before scenario
      Within background
      .--After scenario
      Before scenario
      Within background
      .After scenario


      2 scenarios (2 passed)
      3 steps (3 passed)

      """
      
