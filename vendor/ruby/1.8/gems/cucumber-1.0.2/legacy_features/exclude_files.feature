Feature: Exclude ruby and feature files from runs
  Developers should be able to easily exclude files from cucumber runs
  This is a nice feature to have in conjunction with profiles, so you can exclude
  certain environment files from certain runs.

  Scenario: exclude ruby files
    Given a standard Cucumber project directory structure
    And a file named "features/support/dont_require_me.rb"
    And a file named "features/step_definitions/fooz.rb"
    And a file named "features/step_definitions/foof.rb"
    And a file named "features/step_definitions/foot.rb"
    And a file named "features/support/require_me.rb"

    When I run cucumber features -q --verbose --exclude features/support/dont --exclude foo[zf]

    Then "features/support/require_me.rb" should be required
    And "features/step_definitions/foot.rb" should be required
    And "features/support/dont_require_me.rb" should not be required
    And "features/step_definitions/foof.rb" should not be required
    And "features/step_definitions/fooz.rb" should not be required
