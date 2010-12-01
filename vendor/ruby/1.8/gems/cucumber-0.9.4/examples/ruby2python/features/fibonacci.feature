Feature: Fibonacci
  In order to calculate super fast fibonacci series
  As a pythonista
  I want to use Python for that
  
  Scenario Outline: Series
    When I ask python to calculate fibonacci up to <n>
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
  
