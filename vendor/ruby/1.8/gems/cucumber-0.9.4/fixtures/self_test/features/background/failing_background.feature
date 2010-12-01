@after_file
Feature: Failing background sample
  
  Background:
    Given failing without a table
    And '10' cukes
    
  Scenario: failing background
    Then I should have '10' cukes
    
  Scenario: another failing background
    Then I should have '10' cukes