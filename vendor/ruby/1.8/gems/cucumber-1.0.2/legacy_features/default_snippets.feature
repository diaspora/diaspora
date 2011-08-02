Feature: Print snippets
  In order to make it easier to implement step definitions
  Developers should get a scaffolding for undefined step definitions
  
  Scenario: Cucumber doesn't know what language, and defaults to Ruby
    Given a standard Cucumber project directory structure
    And a file named "features/x.feature" with:
      """
      Feature: X
        Scenario: Y
          Given Z
          Given Q
      """
    When I run cucumber features
    Then STDERR should be empty
    And it should pass with
      """
      Feature: X

        Scenario: Y # features/x.feature:2
          Given Z   # features/x.feature:3
          Given Q   # features/x.feature:4

      1 scenario (1 undefined)
      2 steps (2 undefined)

      You can implement step definitions for undefined steps with these snippets:
      
      Given /^Z$/ do
        pending # express the regexp above with the code you wish you had
      end

      Given /^Q$/ do
        pending # express the regexp above with the code you wish you had
      end

      If you want snippets in a different programming language, just make sure a file
      with the appropriate file extension exists where cucumber looks for step definitions.


      """
  