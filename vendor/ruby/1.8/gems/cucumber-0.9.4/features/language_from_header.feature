Feature: Language from header
  In order to simplify command line and
  settings in IDEs, Cucumber should pick
  up parser language from a header.
  
  Scenario: LOLCAT
    Given a standard Cucumber project directory structure
    And a file named "features/lolcat.feature" with:
      """
      # language: en-lol
      OH HAI: STUFFING
        B4: HUNGRY
        MISHUN: CUKES
          DEN KTHXBAI
      """
    When I run cucumber -i features/lolcat.feature
    Then it should pass with
      """
      # language: en-lol
      OH HAI: STUFFING

        B4: HUNGRY # features/lolcat.feature:3

        MISHUN: CUKES # features/lolcat.feature:4
          DEN KTHXBAI # features/lolcat.feature:5

      1 scenario (1 undefined)
      1 step (1 undefined)

      """
