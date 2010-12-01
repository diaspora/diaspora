Feature: Pending background sample

  Background:
    Given pending

  Scenario: pending background
    Then I should have '10' cukes
    
  Scenario: another pending background
    Then I should have '10' cukes