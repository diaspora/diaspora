Feature: Snippets
  In order to help speed up writing step definitions
  As a feature editor
  I want snippet suggestions for undefined step definitions

  Scenario: Snippet for undefined step with a pystring
    When I run cucumber features/undefined_multiline_args.feature:3 -s
    Then the output should contain
      """
      Given /^a pystring$/ do |string|
        pending # express the regexp above with the code you wish you had
      end
      """

  Scenario: Snippet for undefined step with a step table
    When I run cucumber features/undefined_multiline_args.feature:9 -s
    Then the output should contain
      """
      Given /^a table$/ do |table|
        # table is a Cucumber::Ast::Table
        pending # express the regexp above with the code you wish you had
      end
      """