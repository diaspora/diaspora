Feature: Fibonacci
  In order to calculate super fast fibonacci series
  As a Javascriptist
  I want to use Javascript for that

  Scenario Outline: Series
    When I ask Javascript to calculate fibonacci up to <n>
    Then it should give me <series>

    Examples:
      | n   | series                                 |
      | 1   | []                                     |
      | 2   | [1, 1]                                 |
      | 3   | [1, 1, 2]                              |
      | 4   | [1, 1, 2, 3]                           |
      | 6   | [1, 1, 2, 3, 5]                        |
      | 9   | [1, 1, 2, 3, 5, 8]                     |
      | 100 | [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89] |

  Scenario: Single series tested via a DocString
    When I ask Javascript to calculate fibonacci up to 2 with formatting
    Then it should give me:
    """

    '[1, 1]'

    """

  Scenario: Single series tested via a Step Table
    When I ask Javascript to calculate fibonacci up to 2
    Then it should contain:
    | cell 1 | cell 2 |
    |   1    |   1    |

  @do-fibonnacci-in-before-hook @reviewed
  Scenario: Single series with Before hook with a tag label
    Then it should give me [1, 1, 2]

  Scenario: Single series by calling a step from within a step
    Then it should give me [1, 1] via calling another step definition

  Scenario: Single series by calling multiple steps from within a step
    Then it should calculate fibonacci up to 2 giving me [1, 1]