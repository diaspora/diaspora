Feature: search examples

  Background: The background
    Given passing without a table

  Scenario: should match Hantu Pisang
    Given passing without a table

  Scenario: Ignore me
    Given failing without a table

  Scenario Outline: Ignore me
    Given <state> without a table

    Examples: 
      | state   |
      | 1111111 |

  Scenario Outline: Hantu Pisang match
    Given <state> without a table

    Examples: 
      | state   |
      | 2222222 |

  Scenario Outline: no match in name but in examples
    Given <state> without a table

    Examples: Hantu Pisang
      | state   |
      | 3333333 |

    Examples: Ignore me
      | state   |
      | 4444444 |
