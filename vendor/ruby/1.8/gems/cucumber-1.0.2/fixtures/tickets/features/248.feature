Feature: pending method causes failure in Scenario Outlines 

  Scenario Outline: blah
    Given this is pending until we fix it
    Given context with <Stuff>
    When action
    Then outcome with <Blah>

  Examples:
    | Stuff  | Blah        |
    | Cheese | Pepper Jack |
