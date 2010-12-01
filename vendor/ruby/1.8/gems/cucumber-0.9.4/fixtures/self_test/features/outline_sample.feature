Feature: Outline Sample

  Scenario: I have no steps

  Scenario Outline: Test state
    Given <state> without a table
    Given <other_state> without a table
  Examples: Rainbow colours
    |  state   | other_state |
    | missing |  passing|
    | passing| passing |
| failing | passing |
Examples:Only passing
|  state   | other_state |
| passing  | passing |