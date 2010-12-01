Feature: Delayed announcement

  Background:
    Given a standard Cucumber project directory structure
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /^I use announce with text "(.*)"$/ do |ann| x=1
        announce(ann)
      end

      Given /^I use multiple announces$/ do x=1
        announce("Multiple")
        announce(["Announce","Me"])
      end

      Given /^I use announcement (.+) in line (.+) (?:with result (.+))$/ do |ann, line, result| x=1
        announce("Last announcement") if line == "3"
        announce("Line: #{line}: #{ann}")
        fail if result =~ /fail/i
      end

      Given /^I use announce and step fails$/ do x=1
        announce("Announce with fail")
        fail
      end

      Given /^this step works$/ do x=1
      end

      Given /^I announce the world$/ do x=1
        announce_world
      end
      """
    And a file named "features/f.feature" with:
      """
      Feature: F

        Scenario: S
          Given I use announce with text "Ann"
          And this step works

        Scenario: S2
          Given I use multiple announces
          And this step works

        Scenario Outline: S3
          Given I use announcement <ann> in line <line>

          Examples:
            | line | ann |
            | 1 | anno1 |
            | 2 | anno2 |
            | 3 | anno3 |

        Scenario: S4
          Given I use announce and step fails
          And this step works

        Scenario Outline: s5
          Given I use announcement <ann> in line <line> with result <result>

          Examples:
            | line | ann | result |
            | 1 | anno1 | fail |
            | 2 | anno2 | pass |
      """

    And a file named "features/announce_world.feature" with:
      """
      Feature: announce_world
        Scenario: announce_world
          Given I announce the world
      """

    Scenario: Delayed announcements feature
      When I run cucumber --format pretty features/f.feature
      Then STDERR should be empty
      And the output should contain
      """
      Feature: F

        Scenario: S                            # features/f.feature:3
          Given I use announce with text "Ann" # features/step_definitions/steps.rb:1
            Ann
          And this step works                  # features/step_definitions/steps.rb:21

        Scenario: S2                     # features/f.feature:7
          Given I use multiple announces # features/step_definitions/steps.rb:5
            Multiple
            Announce
            Me
          And this step works            # features/step_definitions/steps.rb:21

        Scenario Outline: S3                            # features/f.feature:11
          Given I use announcement <ann> in line <line> # features/f.feature:12

          Examples: 
            | line | ann   |
            | 1    | anno1 |
            | 2    | anno2 |
            | 3    | anno3 |

        Scenario: S4                          # features/f.feature:20
          Given I use announce and step fails # features/step_definitions/steps.rb:16
            Announce with fail
             (RuntimeError)
            ./features/step_definitions/steps.rb:18:in `/^I use announce and step fails$/'
            features/f.feature:21:in `Given I use announce and step fails'
          And this step works                 # features/step_definitions/steps.rb:21

        Scenario Outline: s5                                                 # features/f.feature:24
          Given I use announcement <ann> in line <line> with result <result> # features/step_definitions/steps.rb:10

          Examples: 
            | line | ann   | result |
            | 1    | anno1 | fail   |  Line: 1: anno1
             (RuntimeError)
            ./features/step_definitions/steps.rb:13:in `/^I use announcement (.+) in line (.+) (?:with result (.+))$/'
            features/f.feature:25:in `Given I use announcement <ann> in line <line> with result <result>'
            | 2    | anno2 | pass   |  Line: 2: anno2
      """

    Scenario: Non-delayed announcements feature (progress formatter)
      When I run cucumber --format progress features/f.feature
      Then the output should contain
        """
        Ann
        ..
        Multiple

        Announce
        Me
        ..-UUUUUU
        Announce with fail
        F--
        Line: 1: anno1
        FFF
        Line: 2: anno2
        ...
        """

    @rspec2
    Scenario: announce world
      When I run cucumber --format progress features/announce_world.feature
      Then the output should contain
      """
      WORLD:
        Object

        RSpec::Matchers
        Cucumber::RbSupport::RbWorld
      """

    @rspec1
    Scenario: announce world
      When I run cucumber --format progress features/announce_world.feature
      Then the output should contain
      """
      WORLD:
        Object

        Spec::Matchers
        Cucumber::RbSupport::RbWorld
      """
