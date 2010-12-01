Feature: Use * keywords and still get snippets
  In order to make it possible to use * instead of
  Given/When/Then, I should not get an exception
  when I have undefined steps

  Scenario: Use some *
    Given a standard Cucumber project directory structure
    And a file named "features/f.feature" with:
      """
      Feature: F
        Scenario: S
          * I have some cukes
      """
    When I run cucumber features/f.feature
    Then STDERR should be empty
    And it should pass with
      """
      Feature: F

        Scenario: S           # features/f.feature:2
          * I have some cukes # features/f.feature:3
      
      1 scenario (1 undefined)
      1 step (1 undefined)
      
      You can implement step definitions for undefined steps with these snippets:
      
      Given /^I have some cukes$/ do
        pending # express the regexp above with the code you wish you had
      end
      
      If you want snippets in a different programming language, just make sure a file
      with the appropriate file extension exists where cucumber looks for step definitions.

      
      """
