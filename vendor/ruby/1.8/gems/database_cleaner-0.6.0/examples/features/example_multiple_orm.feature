Feature: example
 In order to test DataBase Cleaner
 Here are some scenarios that rely on the DB being clean!

 # Background:
 #   Given I have setup DatabaseCleaner to clean multiple orms

  Scenario: dirty the db
    When I create a widget in one orm
     And I create a widget in another orm
    Then I should see 1 widget in one orm
     And I should see 1 widget in another orm

  Scenario: assume a clean db
    When I create a widget in one orm
    Then I should see 1 widget in one orm
     And I should see 0 widget in another orm

  Scenario: assume a clean db
    When I create a widget in another orm
    Then I should see 0 widget in one orm
     And I should see 1 widget in another orm
