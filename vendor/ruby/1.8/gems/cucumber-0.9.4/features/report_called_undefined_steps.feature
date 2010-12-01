Feature: Cucumber command line
  In order to find out what step definitions need to be implemented
  Developers should always see what step definition is missing

  Scenario: Get info at arbitrary levels of nesting
    When I run cucumber features/call_undefined_step_from_step_def.feature
    Then it should pass with
      """
      Feature: Calling undefined step

        Scenario: Call directly                                # features/call_undefined_step_from_step_def.feature:3
          Given a step definition that calls an undefined step # features/step_definitions/sample_steps.rb:19
            Undefined step: "this does not exist" (Cucumber::Undefined)
            ./features/step_definitions/sample_steps.rb:19:in `/^a step definition that calls an undefined step$/'
            features/call_undefined_step_from_step_def.feature:4:in `Given a step definition that calls an undefined step'

        Scenario: Call via another                                         # features/call_undefined_step_from_step_def.feature:6
          Given call step "a step definition that calls an undefined step" # features/step_definitions/sample_steps.rb:23
            Undefined step: "this does not exist" (Cucumber::Undefined)
            ./features/step_definitions/sample_steps.rb:19:in `/^a step definition that calls an undefined step$/'
            features/call_undefined_step_from_step_def.feature:7:in `Given call step "a step definition that calls an undefined step"'

      2 scenarios (2 undefined)
      2 steps (2 undefined)

      You can implement step definitions for undefined steps with these snippets:

      Given /^this does not exist$/ do
        pending # express the regexp above with the code you wish you had
      end


      """

