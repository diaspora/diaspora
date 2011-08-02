Feature: Multiline description names
  In order to accurately document feature elements
  As a cucumberist
  I want to have multiline names

  Scenario: multiline scenario
    When I run cucumber features/multiline_name.feature --no-snippets
    Then STDERR should be empty
    Then it should pass with
    """
    Feature: multiline

      Background: I'm a multiline name                        # features/multiline_name.feature:3
                  which goes on and on and on for three lines
                  yawn
        Given passing without a table                         # features/step_definitions/sample_steps.rb:12

      Scenario: I'm a multiline name                        # features/multiline_name.feature:8
                which goes on and on and on for three lines
                yawn
        Given passing without a table                       # features/step_definitions/sample_steps.rb:12

      Scenario Outline: I'm a multiline name                        # features/multiline_name.feature:13
                        which goes on and on and on for three lines
                        yawn
        Given <state> without a table                               # features/step_definitions/sample_steps.rb:12

        Examples: 
          | state   |
          | passing |

      Scenario Outline: name          # features/multiline_name.feature:21
        Given <state> without a table # features/step_definitions/sample_steps.rb:12

        Examples: I'm a multiline name
                  which goes on and on and on for three lines
                  yawn
          | state   |
          | passing |

    3 scenarios (3 passed)
    6 steps (6 passed)

    """