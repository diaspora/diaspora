Feature: Listener Debugger
  In order to easily visualise the listener API
  As a developer
  I want a formatter that prints the calls to the listener as a feature is run

  Background:
    Given a standard Cucumber project directory structure

  Scenario: title
    Given a file named "features/sample.feature" with:
      """
      Feature: Sample

        Scenario: Sample
          Given Sample

      """
    When I run cucumber -f debug features/sample.feature
    Then STDERR should be empty
    Then it should pass with
      """
      before_features
        before_feature
          before_tags
          after_tags
          feature_name
          before_feature_element
            before_tags
            after_tags
            scenario_name
            before_steps
              before_step
                before_step_result
                  step_name
                after_step_result
              after_step
            after_steps
          after_feature_element
        after_feature
      after_features

      """
