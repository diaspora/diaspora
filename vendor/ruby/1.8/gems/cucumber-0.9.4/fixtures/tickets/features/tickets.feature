Feature: Cucumber
  In order to have a happy user base
  As a Cucumber user
  I don't want no stinkin bugs

  Scenario: RSpec be_*
    Given be_empty
    
  Scenario: Call step from step
    Given nested step is called
    Then nested step should be executed

  Scenario: Call step from step using text table
    Given nested step is called using text table
    Then nested step should be executed
    
  Scenario: Reading a table
    Given the following table
      | born  | working |
      | Oslo  | London  |
    Then I should be working in London
    And I should be born in Oslo
    And I should see a multiline string like
      """
      A string
      that spans
      several lines
      """