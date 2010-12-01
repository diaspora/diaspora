Feature: Cucumber command line
  In order to write better software
  Developers should be able to execute requirements as tests

  Scenario: Run scenario outline with filtering on outline name
    When I run cucumber -q features --name "Test state"
    Then it should fail with
      """
      Feature: Outline Sample

        Scenario Outline: Test state
          Given <state> without a table
          Given <other_state> without a table

          Examples: Rainbow colours
            | state   | other_state |
            | missing | passing     |
            | passing | passing     |
            | failing | passing     |
            FAIL (RuntimeError)
            ./features/step_definitions/sample_steps.rb:2:in `flunker'
            ./features/step_definitions/sample_steps.rb:16:in `/^failing without a table$/'
            features/outline_sample.feature:6:in `Given <state> without a table'

          Examples: Only passing
            | state   | other_state |
            | passing | passing     |

      Failing Scenarios:
      cucumber features/outline_sample.feature:5 # Scenario: Test state

      4 scenarios (1 failed, 1 undefined, 2 passed)
      8 steps (1 failed, 2 skipped, 1 undefined, 4 passed)

      """

  Scenario: Run scenario outline steps only
    When I run cucumber -q features/outline_sample.feature:7
    Then it should fail with
      """
      Feature: Outline Sample

        Scenario Outline: Test state
          Given <state> without a table
          Given <other_state> without a table

          Examples: Rainbow colours
            | state   | other_state |
            | missing | passing     |
            | passing | passing     |
            | failing | passing     |
            FAIL (RuntimeError)
            ./features/step_definitions/sample_steps.rb:2:in `flunker'
            ./features/step_definitions/sample_steps.rb:16:in `/^failing without a table$/'
            features/outline_sample.feature:6:in `Given <state> without a table'

          Examples: Only passing
            | state   | other_state |
            | passing | passing     |

      Failing Scenarios:
      cucumber features/outline_sample.feature:5 # Scenario: Test state

      4 scenarios (1 failed, 1 undefined, 2 passed)
      8 steps (1 failed, 2 skipped, 1 undefined, 4 passed)

      """

  Scenario: Run single failing scenario outline table row
    When I run cucumber features/outline_sample.feature:12
    Then it should fail with
      """
      Feature: Outline Sample

        Scenario Outline: Test state          # features/outline_sample.feature:5
          Given <state> without a table       # features/step_definitions/sample_steps.rb:15
          Given <other_state> without a table # features/step_definitions/sample_steps.rb:12

          Examples: Rainbow colours
            | state   | other_state |
            | failing | passing     |
            FAIL (RuntimeError)
            ./features/step_definitions/sample_steps.rb:2:in `flunker'
            ./features/step_definitions/sample_steps.rb:16:in `/^failing without a table$/'
            features/outline_sample.feature:6:in `Given <state> without a table'

      Failing Scenarios:
      cucumber features/outline_sample.feature:5 # Scenario: Test state

      1 scenario (1 failed)
      2 steps (1 failed, 1 skipped)

      """

  # There are 10 characters in the progress, but only 8 reported steps. Needs investigation.
  # Looks like we're outputting too many characters.
  Scenario: Run all with progress formatter
    When I run cucumber -q --format progress features/outline_sample.feature
    Then it should fail with
      """
      --U-..F-..

      (::) failed steps (::)

      FAIL (RuntimeError)
      ./features/step_definitions/sample_steps.rb:2:in `flunker'
      ./features/step_definitions/sample_steps.rb:16:in `/^failing without a table$/'
      features/outline_sample.feature:6:in `Given <state> without a table'

      Failing Scenarios:
      cucumber features/outline_sample.feature:5 # Scenario: Test state

      5 scenarios (1 failed, 1 undefined, 3 passed)
      8 steps (1 failed, 2 skipped, 1 undefined, 4 passed)

      """

