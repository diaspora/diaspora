Feature: Passing background with scenario outlines sample

  Background:
    Given '10' cukes

  Scenario Outline: passing background
    Then I should have '<count>' cukes
    Examples:
      |count|
      | 10  |

  Scenario Outline: another passing background
    Then I should have '<count>' cukes
    Examples:
      |count|
      | 10  |
