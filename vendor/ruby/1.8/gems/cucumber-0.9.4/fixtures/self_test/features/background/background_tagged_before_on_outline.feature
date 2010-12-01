@background_tagged_before_on_outline
Feature: Background tagged Before on Outline

  Background: 
    Given passing without a table

  Scenario Outline: passing background
    Then I should have '<count>' cukes

    Examples: 
      | count |
      | 888   |
