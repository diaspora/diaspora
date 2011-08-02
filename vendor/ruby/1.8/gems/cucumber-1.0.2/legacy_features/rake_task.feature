Feature: Rake task
  In order to ease the development process
  As a developer and CI server administrator
  Cucumber features should be executable via Rake

  Background:
    Given a standard Cucumber project directory structure
    And a file named "features/missing_step_definitions.feature" with:
      """
      Feature: Sample

        Scenario: Wanted
          Given I want to run this

        Scenario: Unwanted
          Given I don't want this ran
      """


  Scenario: rake task with a defined profile
    Given the following profile is defined:
      """
      foo: --quiet --no-color features/missing_step_definitions.feature:3
      """
    And a file named "Rakefile" with:
      """
      $LOAD_PATH.unshift(CUCUMBER_LIB)
      require 'cucumber/rake/task'

      Cucumber::Rake::Task.new do |t|
        t.profile = "foo"
      end
      """
    When I run rake cucumber
    Then it should pass
    And the output should contain
      """
      Feature: Sample

        Scenario: Wanted
          Given I want to run this

      1 scenario (1 undefined)
      1 step (1 undefined)
      """

    Scenario: rake task without a profile
      Given a file named "Rakefile" with:
        """
        $LOAD_PATH.unshift(CUCUMBER_LIB)
        require 'cucumber/rake/task'

        Cucumber::Rake::Task.new do |t|
          t.cucumber_opts = %w{--quiet --no-color}
        end
        """
      When I run rake cucumber
      Then it should pass
      And the output should contain
        """
        Feature: Sample

          Scenario: Wanted
            Given I want to run this

          Scenario: Unwanted
            Given I don't want this ran

        2 scenarios (2 undefined)
        2 steps (2 undefined)
        """

  Scenario: rake task with a defined profile and cucumber_opts
    Given the following profile is defined:
      """
      bar: ['features/missing_step_definitions.feature:3']
      """
    And a file named "Rakefile" with:
      """
      $LOAD_PATH.unshift(CUCUMBER_LIB)
      require 'cucumber/rake/task'

      Cucumber::Rake::Task.new do |t|
        t.profile = "bar"
        t.cucumber_opts = %w{--quiet --no-color}
      end
      """
    When I run rake cucumber
    Then it should pass
    And the output should contain
      """
      Feature: Sample

        Scenario: Wanted
          Given I want to run this

      1 scenario (1 undefined)
      1 step (1 undefined)
      """

  Scenario: respect requires
    Given a file named "features/support/env.rb"
    And a file named "features/support/dont_require_me.rb"
    And the following profile is defined:
      """
      no_bomb: features/missing_step_definitions.feature:3 --require features/support/env.rb --verbose
      """
    And a file named "Rakefile" with:
      """
      $LOAD_PATH.unshift(CUCUMBER_LIB)
      require 'cucumber/rake/task'

      Cucumber::Rake::Task.new do |t|
        t.profile = "no_bomb"
        t.cucumber_opts = %w{--quiet --no-color}
      end
      """

    When I run rake cucumber
    Then it should pass
    And the output should not contain
      """
        * features/support/dont_require_me.rb
      """

  Scenario: feature files with spaces
    Given a file named "features/spaces are nasty.feature" with:
       """
       Feature: The futures green

         Scenario: Orange
           Given this is missing
       """
    And a file named "Rakefile" with:
       """
       $LOAD_PATH.unshift(CUCUMBER_LIB)
       require 'cucumber/rake/task'

       Cucumber::Rake::Task.new do |t|
         t.cucumber_opts = %w{--quiet --no-color}
       end
       """
    When I run rake cucumber
    Then it should pass
    And the output should contain
       """
       Feature: The futures green

         Scenario: Orange
           Given this is missing

       """
