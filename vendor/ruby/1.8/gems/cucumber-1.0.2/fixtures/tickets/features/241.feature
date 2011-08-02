# Users want to use cucumber, so tests are necessary to verify
# it is all working as expected
Feature: Using the Console Formatter
  In order to verify this error
  I want to run this feature using the progress format
  So that it can be fixed
  
  Scenario: A normal feature
    Given I have a pending step
    When  I run this feature with the progress format
    Then  I should get a no method error for 'backtrace_line'

