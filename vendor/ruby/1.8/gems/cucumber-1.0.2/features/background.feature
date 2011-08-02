Feature: Background
  In order to provide a context to my scenarios within a feature
  As a feature editor
  I want to write a background section in my features.

  Background:
    Given a file named "features/passing_background.feature" with:
      """
      Feature: Passing background sample

        Background:
          Given '10' cukes

        Scenario: passing background
          Then I should have '10' cukes    

        Scenario: another passing background
          Then I should have '10' cukes
      """
    And a file named "features/scenario_outline_passing_background.feature" with:
      """
      Feature: Passing background with scenario outlines sample

        Background:
          Given '10' cukes

        Scenario Outline: passing background
          Then I should have '<count>' cukes
          Examples:
            |count|
            | 10  |

        Scenario Outline: another passing background
          Then I should have '<count>' cukes
          Examples:
            |count|
            | 10  |
      """
    And a file named "features/background_tagged_before_on_outline.feature" with:
      """
      @background_tagged_before_on_outline
      Feature: Background tagged Before on Outline

        Background: 
          Given passing without a table

        Scenario Outline: passing background
          Then I should have '<count>' cukes

          Examples: 
            | count |
            | 888   |
      """
    And a file named "features/failing_background.feature" with:
      """
      Feature: Failing background sample

        Background:
          Given failing without a table
          And '10' cukes

        Scenario: failing background
          Then I should have '10' cukes

        Scenario: another failing background
          Then I should have '10' cukes
      """
    And a file named "features/scenario_outline_failing_background.feature" with:
      """
      Feature: Failing background with scenario outlines sample

        Background:
          Given failing without a table

        Scenario Outline: failing background
          Then I should have '<count>' cukes
          Examples:
            |count|
            | 10  |

        Scenario Outline: another failing background
          Then I should have '<count>' cukes
          Examples:
            |count|
            | 10  |
      """
    And a file named "features/pending_background.feature" with:
      """
      Feature: Pending background sample

        Background:
          Given pending

        Scenario: pending background
          Then I should have '10' cukes

        Scenario: another pending background
          Then I should have '10' cukes
      """
    And a file named "features/failing_background_after_success.feature" with:
      """
      Feature: Failing background after previously successful background sample

        Background:
          Given passing without a table
          And '10' global cukes

        Scenario: passing background
          Then I should have '10' global cukes

        Scenario: failing background
          Then I should have '10' global cukes
      """
    And a file named "features/multiline_args_background.feature" with:
      """
      Feature: Passing background with multiline args

        Background:
          Given table
            |a|b|
            |c|d|
          And multiline string
            \"\"\"
            I'm a cucumber and I'm okay. 
            I sleep all night and I test all day
            \"\"\"

        Scenario: passing background
          Then the table should be
            |a|b|
            |c|d|
          Then the multiline string should be
            \"\"\"
            I'm a cucumber and I'm okay. 
            I sleep all night and I test all day
            \"\"\"

        Scenario: another passing background
          Then the table should be
            |a|b|
            |c|d|
          Then the multiline string should be
            \"\"\"
            I'm a cucumber and I'm okay. 
            I sleep all night and I test all day
            \"\"\"
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      def flunker
        raise "FAIL"
      end

      Given /^'(.+)' cukes$/ do |cukes| x=1
        raise "We already have #{@cukes} cukes!" if @cukes
        @cukes = cukes
      end

      Given(/^passing without a table$/) do
      end

      Given /^failing without a table$/ do x=1
        flunker
      end

      Given /^'(.+)' global cukes$/ do |cukes| x=1
        $scenario_runs ||= 0
        flunker if $scenario_runs >= 1
        $cukes = cukes
        $scenario_runs += 1
      end

      Then /^I should have '(.+)' global cukes$/ do |cukes| x=1
        $cukes.should == cukes
      end

      Then /^I should have '(.+)' cukes$/ do |cukes| x=1
        @cukes.should == cukes
      end

      Before('@background_tagged_before_on_outline') do
        @cukes = '888'
      end

      After('@background_tagged_before_on_outline') do
        @cukes.should == '888'
      end
      """

  Scenario: run a specific scenario with a background
    When I run `cucumber -q features/passing_background.feature:9`
    Then it should pass with exactly:
    """
    Feature: Passing background sample
    
      Background: 
        Given '10' cukes

      Scenario: another passing background
        Then I should have '10' cukes

    1 scenario (1 passed)
    2 steps (2 passed)
    0m0.012s

    """
  
  Scenario: run a feature with a background that passes
    When I run `cucumber -q features/passing_background.feature`
    Then it should pass with exactly:
    """
    Feature: Passing background sample

      Background: 
        Given '10' cukes

      Scenario: passing background
        Then I should have '10' cukes

      Scenario: another passing background
        Then I should have '10' cukes

    2 scenarios (2 passed)
    4 steps (4 passed)
    0m0.012s

    """

  Scenario: run a feature with scenario outlines that has a background that passes
    When I run `cucumber -q features/scenario_outline_passing_background.feature`
    Then it should pass with exactly:
    """
    Feature: Passing background with scenario outlines sample

      Background: 
        Given '10' cukes

      Scenario Outline: passing background
        Then I should have '<count>' cukes

        Examples: 
          | count |
          | 10    |

      Scenario Outline: another passing background
        Then I should have '<count>' cukes

        Examples: 
          | count |
          | 10    |

    2 scenarios (2 passed)
    4 steps (4 passed)
    0m0.012s

    """

  Scenario: run a feature with scenario outlines that has a background that passes
    When I run `cucumber -q features/background_tagged_before_on_outline.feature`
    Then it should pass with exactly:
    """
    @background_tagged_before_on_outline
    Feature: Background tagged Before on Outline

      Background: 
        Given passing without a table

      Scenario Outline: passing background
        Then I should have '<count>' cukes

        Examples: 
          | count |
          | 888   |

    1 scenario (1 passed)
    2 steps (2 passed)
    0m0.012s

    """

  Scenario: run a feature with a background that fails
    When I run `cucumber -q features/failing_background.feature`
    Then it should fail with exactly:
    """
    Feature: Failing background sample

      Background: 
        Given failing without a table
          FAIL (RuntimeError)
          ./features/step_definitions/steps.rb:2:in `flunker'
          ./features/step_definitions/steps.rb:14:in `/^failing without a table$/'
          features/failing_background.feature:4:in `Given failing without a table'
        And '10' cukes

      Scenario: failing background
        Then I should have '10' cukes

      Scenario: another failing background
        Then I should have '10' cukes

    Failing Scenarios:
    cucumber features/failing_background.feature:7
    
    2 scenarios (1 failed, 1 skipped)
    6 steps (1 failed, 5 skipped)
    0m0.012s
    
    """

  Scenario: run a feature with scenario outlines that has a background that fails
    When I run `cucumber -q features/scenario_outline_failing_background.feature`
    Then it should fail with exactly:
    """
    Feature: Failing background with scenario outlines sample

      Background: 
        Given failing without a table
          FAIL (RuntimeError)
          ./features/step_definitions/steps.rb:2:in `flunker'
          ./features/step_definitions/steps.rb:14:in `/^failing without a table$/'
          features/scenario_outline_failing_background.feature:4:in `Given failing without a table'

      Scenario Outline: failing background
        Then I should have '<count>' cukes

        Examples: 
          | count |
          | 10    |

      Scenario Outline: another failing background
        Then I should have '<count>' cukes

        Examples: 
          | count |
          | 10    |

    Failing Scenarios:
    cucumber features/scenario_outline_failing_background.feature:6

    2 scenarios (1 failed, 1 skipped)
    4 steps (1 failed, 3 skipped)
    0m0.012s
    
    """

  Scenario: run a feature with a background that is pending
    When I run `cucumber -q features/pending_background.feature`
    Then it should pass with exactly:
    """
    Feature: Pending background sample

      Background: 
        Given pending

      Scenario: pending background
        Then I should have '10' cukes

      Scenario: another pending background
        Then I should have '10' cukes

    2 scenarios (2 undefined)
    4 steps (2 skipped, 2 undefined)
    0m0.012s
    
    """

  Scenario: background passes with first scenario but fails with second
    When I run `cucumber -q features/failing_background_after_success.feature`
    Then it should fail with exactly:
    """
    Feature: Failing background after previously successful background sample

      Background: 
        Given passing without a table
        And '10' global cukes

      Scenario: passing background
        Then I should have '10' global cukes

      Scenario: failing background
        And '10' global cukes
          FAIL (RuntimeError)
          ./features/step_definitions/steps.rb:2:in `flunker'
          ./features/step_definitions/steps.rb:19:in `/^'(.+)' global cukes$/'
          features/failing_background_after_success.feature:5:in `And '10' global cukes'
        Then I should have '10' global cukes

    Failing Scenarios:
    cucumber features/failing_background_after_success.feature:10

    2 scenarios (1 failed, 1 passed)
    6 steps (1 failed, 1 skipped, 4 passed)
    0m0.012s
    
    """

  Scenario: background with multline args
    Given a file named "features/step_definitions/multiline_steps.rb" with:
      """
      Given /^table$/ do |table| x=1
        @table = table
      end

      Given /^multiline string$/ do |string| x=1
        @multiline = string
      end

      Then /^the table should be$/ do |table| x=1
        @table.raw.should == table.raw
      end

      Then /^the multiline string should be$/ do |string| x=1
        @multiline.should == string
      end
      """
    When I run `cucumber -q features/multiline_args_background.feature`
    Then it should pass with exactly:
      """
      Feature: Passing background with multiline args

        Background: 
          Given table
            | a | b |
            | c | d |
          And multiline string
            \"\"\"
            I'm a cucumber and I'm okay. 
            I sleep all night and I test all day
            \"\"\"

        Scenario: passing background
          Then the table should be
            | a | b |
            | c | d |
          Then the multiline string should be
            \"\"\"
            I'm a cucumber and I'm okay. 
            I sleep all night and I test all day
            \"\"\"

        Scenario: another passing background
          Then the table should be
            | a | b |
            | c | d |
          Then the multiline string should be
            \"\"\"
            I'm a cucumber and I'm okay. 
            I sleep all night and I test all day
            \"\"\"

      2 scenarios (2 passed)
      8 steps (8 passed)
      0m0.012s
    
      """

  Scenario: https://rspec.lighthouseapp.com/projects/16211/tickets/329
    Given a file named "features/only_background_and_hooks.feature" with:
      """
      Feature: woo yeah

        Background: Whatever
          Given whatever

      """
    And a file named "features/only_background_and_hooks_steps.rb" with:
      """
      begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end

      Before do
        $before = true
      end

      After do
        $after = true
      end

      Given(/^whatever$/) { $before.should == true; $step = true }

      at_exit do
        $before.should == true
        $step.should == true
        $after.should == true
      end
      """
    When I run `cucumber features/only_background_and_hooks.feature`
    Then it should pass with exactly:
      """
      Feature: woo yeah

        Background: Whatever # features/only_background_and_hooks.feature:3
          Given whatever     # features/only_background_and_hooks_steps.rb:11

      0 scenarios
      1 step (1 passed)
      0m0.012s

      """
