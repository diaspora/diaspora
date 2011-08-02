Feature: https://rspec.lighthouseapp.com/projects/16211/tickets/371
  Scenario: Before runs once
    Given a standard Cucumber project directory structure
    And a file named "features/f.feature" with:
      """
      Feature: F
        Scenario: S
          Given G
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Before do
        puts "B"
      end
      Given /G/ do
        puts "G"
      end
      """
    When I run cucumber -q --format pretty --format progress --out progress.txt features/f.feature
    Then it should pass with
      """
      Feature: F

        Scenario: S
          Given G
            B
            G

      1 scenario (1 passed)
      1 step (1 passed)

      """
