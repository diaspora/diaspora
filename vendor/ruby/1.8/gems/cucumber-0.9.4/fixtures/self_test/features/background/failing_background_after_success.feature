Feature: Failing background after previously successful background sample

  Background:
    Given passing without a table
    And '10' global cukes

  Scenario: passing background
    Then I should have '10' global cukes
    
  Scenario: failing background
    Then I should have '10' global cukes