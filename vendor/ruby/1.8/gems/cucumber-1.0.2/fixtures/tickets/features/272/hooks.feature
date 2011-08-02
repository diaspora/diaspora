@intentional_failure
Feature: Hooks
  In order to integrate with my complex environment
  I need to check scenario status in an After block

  @272_failed 
  Scenario: Failed
    Given I fail
    
  @272_undefined
  Scenario: Undefined
    Given I am undefined

  @272_passed
  Scenario: Passed
    Given I pass
    
  @272_outline
  Scenario Outline: Should work too
    Given <something>
    
    Examples:
      | something      |
      | I fail         |
      | I am undefined |
      | I pass         |
