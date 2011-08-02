Feature: Cucumber --work-in-progress switch
  In order to ensure that feature scenarios do not pass until they are expected to
  Developers should be able to run cucumber in a mode that
            - will fail if any scenario passes completely
            - will not fail otherwise

  Background: A passing and a pending feature
    Given a standard Cucumber project directory structure
    Given a file named "features/wip.feature" with:
      """
      Feature: WIP
        @failing
        Scenario: Failing
          Given a failing step

        @undefined
        Scenario: Undefined
          Given an undefined step

        @pending
        Scenario: Pending
          Given a pending step

        @passing
        Scenario: Passing
          Given a passing step
      """
    And a file named "features/passing_outline.feature" with:
      """
      Feature: Not WIP
        Scenario Outline: Passing
          Given a <what> step
          
          Examples:
            | what    |
            | passing |
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /^a failing step$/ do
        raise "I fail"
      end

      Given /^a passing step$/ do
      end

      Given /^a pending step$/ do
        pending
      end
      """

  Scenario: Pass with Failing Scenarios
    When I run cucumber -q -w -t @failing features/wip.feature
    Then STDERR should be empty
    Then it should pass with
      """
      Feature: WIP

        @failing
        Scenario: Failing
          Given a failing step
            I fail (RuntimeError)
            ./features/step_definitions/steps.rb:2:in `/^a failing step$/'
            features/wip.feature:4:in `Given a failing step'
      
      Failing Scenarios:
      cucumber features/wip.feature:3

      1 scenario (1 failed)
      1 step (1 failed)

      The --wip switch was used, so the failures were expected. All is good.

      """

  Scenario: Pass with Undefined Scenarios
    When I run cucumber -q -w -t @undefined features/wip.feature
    Then it should pass with
      """
      Feature: WIP

        @undefined
        Scenario: Undefined
          Given an undefined step

      1 scenario (1 undefined)
      1 step (1 undefined)

      The --wip switch was used, so the failures were expected. All is good.

      """

  Scenario: Pass with Undefined Scenarios
    When I run cucumber -q -w -t @pending features/wip.feature
    Then it should pass with
      """
      Feature: WIP

        @pending
        Scenario: Pending
          Given a pending step
            TODO (Cucumber::Pending)
            ./features/step_definitions/steps.rb:9:in `/^a pending step$/'
            features/wip.feature:12:in `Given a pending step'

      1 scenario (1 pending)
      1 step (1 pending)

      The --wip switch was used, so the failures were expected. All is good.

      """

  Scenario: Fail with Passing Scenarios
    When I run cucumber -q -w -t @passing features/wip.feature
    Then it should fail with
      """
      Feature: WIP

        @passing
        Scenario: Passing
          Given a passing step

      1 scenario (1 passed)
      1 step (1 passed)

      The --wip switch was used, so I didn't expect anything to pass. These scenarios passed:
      (::) passed scenarios (::)

      features/wip.feature:15:in `Scenario: Passing'


      """

  Scenario: Fail with Passing Scenario Outline
    When I run cucumber -q -w features/passing_outline.feature
    Then it should fail with
      """
      Feature: Not WIP

        Scenario Outline: Passing
          Given a <what> step
      
          Examples: 
            | what    |
            | passing |

      1 scenario (1 passed)
      1 step (1 passed)

      The --wip switch was used, so I didn't expect anything to pass. These scenarios passed:
      (::) passed scenarios (::)

      features/passing_outline.feature:7:in `| passing |'


      """
