Feature: Fibonacci
  In order to calculate super fast fibonacci series
  As a Tcl hacker
  I want to use Tcl for that
  
  Scenario Outline: Series
    When I ask Tcl to calculate fibonacci for <n>
    Then it should give me <result>
    Examples:
      | n | result |
      | 1 | 1      |
      | 2 | 1      |
      | 3 | 2      |
      | 4 | 3      |
      | 5 | 5      |
      | 6 | 8      |
  
