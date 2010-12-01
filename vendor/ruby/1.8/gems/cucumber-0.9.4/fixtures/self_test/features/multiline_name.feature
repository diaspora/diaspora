Feature: multiline

  Background: I'm a multiline name
              which goes on and on and on for three lines
              yawn
    Given passing without a table

  Scenario: I'm a multiline name
            which goes on and on and on for three lines
            yawn
    Given passing without a table

  Scenario Outline: I'm a multiline name
                    which goes on and on and on for three lines
                    yawn
    Given <state> without a table 
    Examples:
      | state |
      |passing|

  Scenario Outline: name
    Given <state> without a table 
    Examples: I'm a multiline name
              which goes on and on and on for three lines
              yawn
      | state |
      |passing|