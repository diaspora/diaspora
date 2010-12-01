Feature: backgrounds
  In order to provide a context to my scenarios within a feature
  As a feature editor
  I want to write a background section in my features.

  Scenario: run a specific scenario with a background
    When I run cucumber -q features/background/passing_background.feature:9 --require features
    Then STDERR should be empty
    Then it should pass with
    """
    Feature: Passing background sample
    
      Background: 
        Given '10' cukes

      Scenario: another passing background
        Then I should have '10' cukes

    1 scenario (1 passed)
    2 steps (2 passed)
    
    """
  
  Scenario: run a feature with a background that passes
    When I run cucumber -q features/background/passing_background.feature --require features
    Then it should pass with
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
    
    """

  Scenario: run a feature with scenario outlines that has a background that passes
    When I run cucumber -q features/background/scenario_outline_passing_background.feature --require features
    Then it should pass with
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

    """

  Scenario: run a feature with scenario outlines that has a background that passes
    When I run cucumber -q features/background/background_tagged_before_on_outline.feature --require features
    Then it should pass with
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

    """

  Scenario: run a feature with a background that fails
    When I run cucumber -q features/background/failing_background.feature --require features
    Then it should fail with
    """
    @after_file
    Feature: Failing background sample

      Background: 
        Given failing without a table
          FAIL (RuntimeError)
          ./features/step_definitions/sample_steps.rb:2:in `flunker'
          ./features/step_definitions/sample_steps.rb:16:in `/^failing without a table$/'
          features/background/failing_background.feature:5:in `Given failing without a table'
        And '10' cukes

      Scenario: failing background
        Then I should have '10' cukes

      Scenario: another failing background
        Then I should have '10' cukes

    Failing Scenarios:
    cucumber features/background/failing_background.feature:8 # Scenario: failing background
    
    2 scenarios (1 failed, 1 skipped)
    6 steps (1 failed, 5 skipped)

    """
    And "fixtures/self_test/tmp/after.txt" should exist

  Scenario: run a feature with scenario outlines that has a background that fails
    When I run cucumber -q features/background/scenario_outline_failing_background.feature --require features
    Then it should fail with
    """
    Feature: Failing background with scenario outlines sample

      Background: 
        Given failing without a table
          FAIL (RuntimeError)
          ./features/step_definitions/sample_steps.rb:2:in `flunker'
          ./features/step_definitions/sample_steps.rb:16:in `/^failing without a table$/'
          features/background/scenario_outline_failing_background.feature:4:in `Given failing without a table'

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
    cucumber features/background/scenario_outline_failing_background.feature:6 # Scenario: failing background

    2 scenarios (1 failed, 1 skipped)
    4 steps (1 failed, 3 skipped)

    """

  Scenario: run a feature with a background that is pending
    When I run cucumber -q features/background/pending_background.feature --require features
    Then it should pass with
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

    """

  Scenario: background passes with first scenario but fails with second
    When I run cucumber -q features/background/failing_background_after_success.feature --require features
    Then it should fail with
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
          ./features/step_definitions/sample_steps.rb:2:in `flunker'
          ./features/step_definitions/sample_steps.rb:37:in `/^'(.+)' global cukes$/'
          features/background/failing_background_after_success.feature:5:in `And '10' global cukes'
        Then I should have '10' global cukes

    Failing Scenarios:
    cucumber features/background/failing_background_after_success.feature:10 # Scenario: failing background

    2 scenarios (1 failed, 1 passed)
    6 steps (1 failed, 1 skipped, 4 passed)

    """

  Scenario: background with multline args
  When I run cucumber -q features/background/multiline_args_background.feature --require features
  Then it should pass with
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
    
    """

  Scenario: background with name
    When I run cucumber -q features/background/background_with_name.feature --require features
    Then it should pass with
    """
    Feature: background with name

      Background: I'm a background and I'm ok
        Given '10' cukes

      Scenario: example
        Then I should have '10' cukes

    1 scenario (1 passed)
    2 steps (2 passed)
    
    """

  Scenario: https://rspec.lighthouseapp.com/projects/16211/tickets/329
    Given a standard Cucumber project directory structure
    And a file named "features/only_background_and_hooks.feature" with:
      """
      Feature: woo yeah

        Background:
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
    When I run cucumber features/only_background_and_hooks.feature 
    Then it should pass
    And the output should be
      """
      Feature: woo yeah

        Background:      # features/only_background_and_hooks.feature:3
          Given whatever # features/only_background_and_hooks_steps.rb:11

      0 scenarios
      1 step (1 passed)
      
      """
    And STDERR should be empty
