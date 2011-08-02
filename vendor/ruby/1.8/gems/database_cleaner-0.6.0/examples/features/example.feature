Feature: example
 In order to test DataBase Cleaner
 Here are some scenarios that rely on the DB being clean!

  Scenario: dirty the db
    When I create a widget
    Then I should see 1 widget

  Scenario: assume a clean db
    When I create a widget
    Then I should see 1 widget
