# language: en
Feature: Gherkin Feature lexer
  In order to make it easy to control the Gherkin syntax
  As a Gherkin developer bent on Gherkin world-domination
  I want a feature lexer that uses a feature parser to
  make all the syntax decisions for me

  Background: 
    Given a "ruby" "root" parser

  Scenario: Correctly formed feature
    Given the following text is parsed:
      """
      # Apologies to Bill Watterson
      @cardboard_box @wip
      Feature: Transmogrification
        As a young boy with a hyperactive imagination
        I want a cardboard box
        In order to transform the ennui of suburban life into something
          befitting my imagination
        
        Background: 
          Given I have a transmogrifier
          And I am a member of G.R.O.S.S
      
        Scenario: Whoozit to whatzit transmogrification
          Given I have a whoozit
          When I put it in the transmogrifier
          And I press the "transmogrify" button
          Then I should have a whatzit
      
        Scenario Outline: Imaginary Beings
          Given I have a <boring being>
          When I transmogrify it with the incantation:
          \"\"\"
          ALAKAZAM!
          \"\"\"
          Then I should have an <exciting being>
      
          Examples:
          | boring being | exciting being |
          | Sparrow      | Alicanto       |
          | Goldfish     | Baldanders     |
          | Cow          | Hsiao          |
          
        Scenario: Sense of humor detection
          Given the following excerpt:
            \"\"\"
            WOMAN:  Who are the Britons?
            ARTHUR:  Well, we all are. we're all Britons and I am your king.
            WOMAN:  I didn't know we had a king.  I thought we were an autonomous
                collective.
            DENNIS:  You're fooling yourself.  We're living in a dictatorship.
                A self-perpetuating autocracy in which the working classes--
            WOMAN:  Oh there you go, bringing class into it again.
            DENNIS:  That's what it's all about if only people would--
            ARTHUR:  Please, please good people.  I am in haste.  Who lives
                in that castle?  
            \"\"\"
          When I read it
          Then I should be amused
      """
    Then there should be no parse errors

  Scenario: Keyword before feature
    Given the following text is parsed:
      """
      Scenario: Bullying my way to the head of the line
        Given I am a big bully of a scenario
        Then I should be caught by the syntax police(y)
      
      Feature: Too timid to stand up for myself
      """
    Then there should be parse errors on lines 1 through 3

  Scenario: Multiple Features in file
    Given the following text is parsed:
      """
      Feature: 
        Scenario: Hi
      Feature: Uh ohs
        Scenario Outline:
      Feature: This is silly
      """
    Then there should be parse errors on lines 3 and 5

  Scenario: Tag ends background and scenario
    Given the following text is parsed:
      """
      Feature: test feature
        Background:
          Given a something
          @tag
          And something else
          
      @foo
      Scenario: my scenario
        @tag
        Given this is a step
        @oh_hai
        And this is a horrible idea
        Then it shouldn't work
      """
    Then there should be parse errors on lines 5, 10 and 12

  Scenario: Malformed Tables
    Given the following text is parsed:
      """
      Feature: Antiques Roadshow
      Scenario Outline: Table
        Given a <foo>
        Then a <bar>        
        
      Examples:
        | foo | bar   |
        | 42  | towel |
        @hello
        | 1   | prime |
        
      Scenario: Table arguments
        Given this step needs this table:
        | foo | bar |
        | one | two |
        @tag
        | aaa | bbb |
      """
    Then there should be parse errors on lines 10 and 17

  Scenario: Well-formed Tables
    Given the following text is parsed:
      """
      Feature: Row-by-row
      
      Scenario: Tables with comments!
        Given I can now comment out a row:
          | Key  | Value |
          # | Yes  | No  |
          # | Good | Bad |
          | Good | Evil  |
        Then I am pleased by these things:
          | Raindrops     | Roses   |
          # | Whiskers    | Kittens |
          | Bright Copper | Kettles |
          # | Warm woolen   | Mittens |
          | Also Oban | And Hendricks |
      """
    Then there should be no parse errors

  Scenario: Multiline keyword descriptions
    Given the following text is parsed:
      """
        Feature: Documentation is fun
          Scenario Outline: With lots of docs
            We need lots of embedded documentation for some reason 
            \"\"\" # Not interpreted as a pystring, just plain text
            Oh hai
            \"\"\"
      
            La la la
      
            Examples:
            | one | two |
            | foo | bar |
      
            \"\"\"
            Oh Hello
            \"\"\"
      
            # Body of the scenario outline starts below
            Given <something> 
            And something <else>
      
            # The real examples table
            Examples: 
            | something | else |
            | orange | apple |
      """
    Then there should be no parse errors

  Scenario: Scenario Outline with multiple Example groups
    Given the following text is parsed:
      """
      Feature: Outline Sample
      
        Scenario: I have no steps
      
        Scenario Outline: Test state
          Given <state> without a table
          Given <other_state> without a table
      
          Examples: Rainbow colours
            | state   | other_state |
            | missing | passing     |
            | passing | passing     |
            | failing | passing     |
          
          Examples: Only passing
            | state   | other_state |
            | passing | passing     |
      """
    Then there should be no parse errors

  Scenario: Multiple Scenario Outlines with multiline outline steps
    Given the following text is parsed:
      """
      Feature: Test
        Scenario Outline: with step tables
          Given I have the following fruits in my pantry
            | name        | quantity |
            | cucumbers   | 10       |
            | strawberrys | 5        |
            | apricots    | 7        |
      
          When I eat <number> <fruits> from the pantry
          Then I should have <left> <fruits> in the pantry
      
          Examples:
            | number | fruits      | left |
            | 2      | cucumbers   | 8    |
            | 4      | strawberrys | 1    |
            | 2      | apricots    | 5    |
      
        Scenario Outline: placeholder in a multiline string
          Given my shopping list
            \"\"\"
              Must buy some <fruits>
            \"\"\"
          Then my shopping list should equal
            \"\"\"
              Must buy some cucumbers
            \"\"\"
      
          Examples:
            | fruits    |
            | cucumbers |
      """
    Then there should be no parse errors
