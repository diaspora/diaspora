Feature: https://rspec.lighthouseapp.com/projects/16211/tickets/464
  Scenario: Limiting with tags which do not exist in the features
    Given a standard Cucumber project directory structure
    And a file named "features/f.feature" with:
      """
      Feature: Test
      In order to test
      As a tester
      I want to test

        @tag
        Scenario: Testing
          Given I'm a test
      """
    When I run cucumber -q features/f.feature --tag @i_dont_exist
    Then it should pass