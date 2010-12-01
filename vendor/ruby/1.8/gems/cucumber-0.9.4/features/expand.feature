Feature: --expand option
  In order to make it easier to writhe certain editor plugins
  and also for some people to understand scenarios, Cucumber
  should expand examples in outlines.

  Background:
    Given a standard Cucumber project directory structure
    And a file named "features/expand_me.feature" with:
      """
      Feature: submit guess

        Background: 
          Given the players' names:
            | maker    | breaker   |
            | Moriarty | Holmes    |
 
        Scenario Outline: submit guess
          Given the secret code is <code>
          When I guess <guess>
          Then the mark should be <mark>

        Examples: all colors correct
          | code    | guess   | mark |
          | r g y c | r g y c | bbbb |
          | r g y c | r g c y | bbww |
      """

  Scenario: Expand the outline
    When I run cucumber -i -q --expand features/expand_me.feature
    Then STDERR should be empty
    And it should pass with
      """
      Feature: submit guess

        Background: 
          Given the players' names:
            | maker    | breaker |
            | Moriarty | Holmes  |

        Scenario Outline: submit guess
          Given the secret code is <code>
          When I guess <guess>
          Then the mark should be <mark>

          Examples: all colors correct

            Scenario: | r g y c | r g y c | bbbb |
              Given the secret code is r g y c
              When I guess r g y c
              Then the mark should be bbbb

            Scenario: | r g y c | r g c y | bbww |
              Given the secret code is r g y c
              When I guess r g c y
              Then the mark should be bbww

      2 scenarios (2 undefined)
      8 steps (8 undefined)
      
      """
