Feature: Cucumber command line
  In order to be able to write an editor plugin that can jump between
  steps and step definitions, Cucumber must provide a way to
  display how they are related.

  Scenario: List usage of step definitions
    When I run cucumber features --format usage --dry-run
    Then STDERR should be empty
    And it should pass with
      """
      -------------------------------------UU-U--------------UUUUU---------U-------U--------------U-UU-------------------------------------------------UU
      
      /^'(.+)' cukes$/                                                   # features/step_definitions/sample_steps.rb:27
        Given '10' cukes                                                 # features/background/background_with_name.feature:4
        Given '10' cukes                                                 # features/background/background_with_name.feature:4
        And '10' cukes                                                   # features/background/failing_background.feature:6
        And '10' cukes                                                   # features/background/failing_background.feature:6
        And '10' cukes                                                   # features/background/failing_background.feature:6
        Given '10' cukes                                                 # features/background/passing_background.feature:4
        Given '10' cukes                                                 # features/background/passing_background.feature:4
        Given '10' cukes                                                 # features/background/passing_background.feature:4
        Given '10' cukes                                                 # features/background/scenario_outline_passing_background.feature:4
        Given '2' cukes                                                  # features/tons_of_cukes.feature:4
        Given '2' cukes                                                  # features/tons_of_cukes.feature:5
        Given '2' cukes                                                  # features/tons_of_cukes.feature:6
        Given '2' cukes                                                  # features/tons_of_cukes.feature:7
        Given '2' cukes                                                  # features/tons_of_cukes.feature:8
        Given '2' cukes                                                  # features/tons_of_cukes.feature:9
        Given '2' cukes                                                  # features/tons_of_cukes.feature:10
        Given '2' cukes                                                  # features/tons_of_cukes.feature:11
        Given '2' cukes                                                  # features/tons_of_cukes.feature:12
        Given '2' cukes                                                  # features/tons_of_cukes.feature:13
        Given '2' cukes                                                  # features/tons_of_cukes.feature:14
        Given '2' cukes                                                  # features/tons_of_cukes.feature:15
        Given '2' cukes                                                  # features/tons_of_cukes.feature:16
        Given '2' cukes                                                  # features/tons_of_cukes.feature:17
        Given '2' cukes                                                  # features/tons_of_cukes.feature:18
        Given '2' cukes                                                  # features/tons_of_cukes.feature:19
        Given '2' cukes                                                  # features/tons_of_cukes.feature:20
        Given '2' cukes                                                  # features/tons_of_cukes.feature:21
        Given '2' cukes                                                  # features/tons_of_cukes.feature:22
        Given '2' cukes                                                  # features/tons_of_cukes.feature:23
        Given '2' cukes                                                  # features/tons_of_cukes.feature:24
        Given '2' cukes                                                  # features/tons_of_cukes.feature:25
        Given '2' cukes                                                  # features/tons_of_cukes.feature:26
        Given '2' cukes                                                  # features/tons_of_cukes.feature:27
        Given '2' cukes                                                  # features/tons_of_cukes.feature:28
        Given '2' cukes                                                  # features/tons_of_cukes.feature:29
        Given '2' cukes                                                  # features/tons_of_cukes.feature:30
        Given '2' cukes                                                  # features/tons_of_cukes.feature:31
        Given '2' cukes                                                  # features/tons_of_cukes.feature:32
        Given '2' cukes                                                  # features/tons_of_cukes.feature:33
        Given '2' cukes                                                  # features/tons_of_cukes.feature:34
        Given '2' cukes                                                  # features/tons_of_cukes.feature:35
        Given '2' cukes                                                  # features/tons_of_cukes.feature:36
        Given '2' cukes                                                  # features/tons_of_cukes.feature:37
        Given '2' cukes                                                  # features/tons_of_cukes.feature:38
        Given '2' cukes                                                  # features/tons_of_cukes.feature:39
        Given '2' cukes                                                  # features/tons_of_cukes.feature:40
        Given '2' cukes                                                  # features/tons_of_cukes.feature:41
        Given '2' cukes                                                  # features/tons_of_cukes.feature:42
        Given '2' cukes                                                  # features/tons_of_cukes.feature:43
        Given '2' cukes                                                  # features/tons_of_cukes.feature:44
        Given '2' cukes                                                  # features/tons_of_cukes.feature:45
        Given '2' cukes                                                  # features/tons_of_cukes.feature:46
        Given '2' cukes                                                  # features/tons_of_cukes.feature:47
        Given '2' cukes                                                  # features/tons_of_cukes.feature:48
        Given '2' cukes                                                  # features/tons_of_cukes.feature:49
        Given '2' cukes                                                  # features/tons_of_cukes.feature:50
        Given '2' cukes                                                  # features/tons_of_cukes.feature:51
        Given '2' cukes                                                  # features/tons_of_cukes.feature:52
      /^'(.+)' global cukes$/                                            # features/step_definitions/sample_steps.rb:35
        And '10' global cukes                                            # features/background/failing_background_after_success.feature:5
        And '10' global cukes                                            # features/background/failing_background_after_success.feature:5
        And '10' global cukes                                            # features/background/failing_background_after_success.feature:5
      /^I should have '(.+)' cukes$/                                     # features/step_definitions/sample_steps.rb:31
        Then I should have '10' cukes                                    # features/background/background_with_name.feature:7
        Then I should have '10' cukes                                    # features/background/failing_background.feature:9
        Then I should have '10' cukes                                    # features/background/failing_background.feature:12
        Then I should have '10' cukes                                    # features/background/passing_background.feature:7
        Then I should have '10' cukes                                    # features/background/passing_background.feature:10
        Then I should have '10' cukes                                    # features/background/pending_background.feature:7
        Then I should have '10' cukes                                    # features/background/pending_background.feature:10
      /^I should have '(.+)' global cukes$/                              # features/step_definitions/sample_steps.rb:42
        Then I should have '10' global cukes                             # features/background/failing_background_after_success.feature:8
        Then I should have '10' global cukes                             # features/background/failing_background_after_success.feature:11
      /^a step definition that calls an undefined step$/                 # features/step_definitions/sample_steps.rb:19
        Given a step definition that calls an undefined step             # features/call_undefined_step_from_step_def.feature:4
      /^another unused$/                                                 # features/step_definitions/sample_steps.rb:69
        NOT MATCHED BY ANY STEPS
      /^call step "(.*)"$/                                               # features/step_definitions/sample_steps.rb:23
        Given call step "a step definition that calls an undefined step" # features/call_undefined_step_from_step_def.feature:7
      /^failing expectation$/                                            # features/step_definitions/sample_steps.rb:62
        Given failing expectation                                        # features/failing_expectation.feature:4
      /^failing without a table$/                                        # features/step_definitions/sample_steps.rb:15
        Given failing without a table                                    # features/background/failing_background.feature:5
        Given failing without a table                                    # features/background/failing_background.feature:5
        Given failing without a table                                    # features/background/failing_background.feature:5
        Given failing without a table                                    # features/background/scenario_outline_failing_background.feature:4
        Given failing without a table                                    # features/search_sample.feature:10
      /^failing$/                                                        # features/step_definitions/sample_steps.rb:8
        Given failing                                                    # features/sample.feature:18
      /^multiline string$/                                               # features/step_definitions/sample_steps.rb:50
        And multiline string                                             # features/background/multiline_args_background.feature:7
        And multiline string                                             # features/background/multiline_args_background.feature:7
        And multiline string                                             # features/background/multiline_args_background.feature:7
      /^passing without a table$/                                        # features/step_definitions/sample_steps.rb:12
        Given passing without a table                                    # features/background/background_tagged_before_on_outline.feature:5
        Given passing without a table                                    # features/background/failing_background_after_success.feature:4
        Given passing without a table                                    # features/background/failing_background_after_success.feature:4
        Given passing without a table                                    # features/background/failing_background_after_success.feature:4
        Given passing without a table                                    # features/multiline_name.feature:6
        Given passing without a table                                    # features/multiline_name.feature:6
        Given passing without a table                                    # features/multiline_name.feature:11
        Given passing without a table                                    # features/search_sample.feature:4
        Given passing without a table                                    # features/search_sample.feature:4
        Given passing without a table                                    # features/search_sample.feature:7
        Given passing without a table                                    # features/search_sample.feature:4
      /^passing$/                                                        # features/step_definitions/sample_steps.rb:5
        Given passing                                                    # features/sample.feature:12
      /^table$/                                                          # features/step_definitions/sample_steps.rb:46
        Given table                                                      # features/background/multiline_args_background.feature:4
        Given table                                                      # features/background/multiline_args_background.feature:4
        Given table                                                      # features/background/multiline_args_background.feature:4
      /^the multiline string should be$/                                 # features/step_definitions/sample_steps.rb:58
        Then the multiline string should be                              # features/background/multiline_args_background.feature:17
        Then the multiline string should be                              # features/background/multiline_args_background.feature:27
      /^the table should be$/                                            # features/step_definitions/sample_steps.rb:54
        Then the table should be                                         # features/background/multiline_args_background.feature:14
        Then the table should be                                         # features/background/multiline_args_background.feature:24
      /^unused$/                                                         # features/step_definitions/sample_steps.rb:66
        NOT MATCHED BY ANY STEPS
      
      43 scenarios (32 skipped, 10 undefined, 1 passed)
      131 steps (117 skipped, 14 undefined)

      """

  Scenario: --format stepdefs
    When I run cucumber features --format stepdefs --dry-run
    Then STDERR should be empty
    And it should pass with
      """
      -------------------------------------UU-U--------------UUUUU---------U-------U--------------U-UU-------------------------------------------------UU
      
      /^'(.+)' cukes$/                                     # features/step_definitions/sample_steps.rb:27
      /^'(.+)' global cukes$/                              # features/step_definitions/sample_steps.rb:35
      /^I should have '(.+)' cukes$/                       # features/step_definitions/sample_steps.rb:31
      /^I should have '(.+)' global cukes$/                # features/step_definitions/sample_steps.rb:42
      /^a step definition that calls an undefined step$/   # features/step_definitions/sample_steps.rb:19
      /^another unused$/                                   # features/step_definitions/sample_steps.rb:69
        NOT MATCHED BY ANY STEPS
      /^call step "(.*)"$/                                 # features/step_definitions/sample_steps.rb:23
      /^failing expectation$/                              # features/step_definitions/sample_steps.rb:62
      /^failing without a table$/                          # features/step_definitions/sample_steps.rb:15
      /^failing$/                                          # features/step_definitions/sample_steps.rb:8
      /^multiline string$/                                 # features/step_definitions/sample_steps.rb:50
      /^passing without a table$/                          # features/step_definitions/sample_steps.rb:12
      /^passing$/                                          # features/step_definitions/sample_steps.rb:5
      /^table$/                                            # features/step_definitions/sample_steps.rb:46
      /^the multiline string should be$/                   # features/step_definitions/sample_steps.rb:58
      /^the table should be$/                              # features/step_definitions/sample_steps.rb:54
      /^unused$/                                           # features/step_definitions/sample_steps.rb:66
        NOT MATCHED BY ANY STEPS
      
      43 scenarios (32 skipped, 10 undefined, 1 passed)
      131 steps (117 skipped, 14 undefined)

      """
