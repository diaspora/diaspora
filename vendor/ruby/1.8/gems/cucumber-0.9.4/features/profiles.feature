Feature: Profiles
  In order to save time and prevent carpal tunnel syndrome
  Cucumber users can save and reuse commonly used cucumber flags in a 'cucumber.yml' file.
  These named arguments are called profiles and the yml file should be in the root of your project.
  Any cucumber argument is valid in a profile.  To see all the available flags type 'cucumber --help'
  For more information about profiles please see the wiki:
  http://wiki.github.com/aslakhellesoy/cucumber/cucumberyml

  Background: Basic App
    Given a standard Cucumber project directory structure
    And a file named "features/sample.feature" with:
      """
      Feature: Sample
        Scenario: this is a test
          Given I am just testing stuff
      """
    And a file named "features/support/env.rb"
    And a file named "features/support/super_env.rb"
    And the following profiles are defined:
      """
      default: features/sample.feature --require features/support/env.rb -v
      super: features/sample.feature --require features/support/super_env.rb -v
      """

  Scenario: Explicitly defining a profile to run
    When I run cucumber features/sample.feature --profile super
    Then the output should contain
      """
      Using the super profile...
      """
    And exactly these files should be loaded: features/support/super_env.rb

  Scenario: Explicitly defining a profile defined in an ERB formatted file
    Given the following profiles are defined:
      """
      <% requires = "--require features/support/super_env.rb" %>
      super: <%= "features/sample.feature #{requires} -v" %>
      """
    When I run cucumber features/sample.feature --profile super
    Then the output should contain
      """
      Using the super profile...
      """
    And exactly these files should be loaded: features/support/super_env.rb

  Scenario: Defining multiple profiles to run
    When I run cucumber features/sample.feature --profile default --profile super
    Then the output should contain
      """
      Using the default and super profiles...
      """
    And exactly these files should be loaded: features/support/env.rb, features/support/super_env.rb

  Scenario: Arguments passed in but no profile specified
    When I run cucumber -v
    Then the default profile should be used
    And exactly these files should be loaded: features/support/env.rb

  Scenario: Trying to use a missing profile
    When I run cucumber -p foo
    Then STDERR should be
      """
      Could not find profile: 'foo'

      Defined profiles in cucumber.yml:
        * default
        * super

      """

  Scenario Outline: Disabling the default profile
    When I run cucumber -v features/ <Flag>
    Then the output should contain
      """
      Disabling profiles...
      """
    And exactly these files should be loaded: features/support/env.rb, features/support/super_env.rb

    Examples:
    |   Flag          |
    | -P              |
    | --no-profile    |


  Scenario: Overriding the profile's features to run
    Given a file named "features/another.feature" with:
      """
      Feature: Just this one should be ran
      """
      When I run cucumber -p default features/another.feature
      Then exactly these features should be ran: features/another.feature

  Scenario: Overriding the profile's formatter
    You will most likely want to define a formatter in your default formatter.
    However, you often want to run your features with a different formatter
    yet still use the other the other arguments in the profile. Cucumber will
    allow you to do this by giving precedence to the formatter specified on the
    command line and override the one in the profile.

    Given the following profiles are defined:
      """
      default: features/sample.feature --require features/support/env.rb -v --format profile
      """
    When I run cucumber features --format pretty
    And the output should contain
      """
      Feature: Sample
      """

  Scenario Outline: Showing profiles when listing failing scenarios
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Given /^I am just testing stuff$/ do
        raise 'BANG'
      end
      """
    When I run cucumber -q -p super -p default -f <format> features/sample.feature --require features/step_definitions/steps.rb
    Then it should fail
    And the output should contain
       """
       cucumber -p super features/sample.feature:2 # Scenario: this is a test
       """
    Examples:
      | format  |
      | pretty  |
      | progress|
