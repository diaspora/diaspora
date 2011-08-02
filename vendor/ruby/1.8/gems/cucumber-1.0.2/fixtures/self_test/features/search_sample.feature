Feature: search examples

  Background: Hantu Pisang background match
    Given passing without a table

  Scenario: should match Hantu Pisang
    Given passing without a table

  Scenario: Ignore me
    Given failing without a table

  Scenario Outline: Ignore me
    Given <state> without a table
    Examples:
      | state   |
      | failing |

  Scenario Outline: Hantu Pisang match
    Given <state> without a table
    Examples:
      | state   |
      | passing |

  Scenario Outline: no match in name but in examples
    Given <state> without a table
    Examples: Hantu Pisang
      | state   |
      | passing |

    Examples: Ignore me
      | state   |
      | failing |
