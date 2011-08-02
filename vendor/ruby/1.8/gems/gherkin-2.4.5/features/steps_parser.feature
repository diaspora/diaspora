Feature: Gherkin Steps parser
  In order to save time and make my features clearer
  As a Cucumber developer
  I want a steps parser to make writing compound steps easier

  Background: 
    Given a "ruby" "steps" parser

  Scenario: Parsing steps
    Given the following text is parsed:
      """
      Given a one step
      And a two step
        \"\"\"
        Here is a multiline string
        That follows a step
        With an argument #{arg}
        \"\"\"
      And a one two three step
      When another step
      Then there should be a table
        | one | two | three  |
        | foo | bar | #{arg} |
      """
    Then there should be no parse errors

  Scenario: Trying to parse a full feature with the step parser
    Given the following text is parsed:
      """
      Feature: A Feature
        Scenario: Yes, there is one
          Given I have a step
          When I execute this step
          Then something should happen
      """
    Then there should be parse errors on lines 1 and 2

  Scenario: Tags
    Given the following text is parsed:
      """
      @a_tag
      Given a step
      When I trip
      Then I should sign up for dancing lessons
      """
    Then there should be a parse error on line 1
