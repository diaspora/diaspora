Feature: example
 In order to test DataBase Cleaner
 Here are some scenarios that rely on the DB being clean!

  # Background:
  #   Given I have setup DatabaseCleaner to clean multiple databases
  #
  Scenario: dirty the db
    When I create a widget in one db
     And I create a widget in another db
    Then I should see 1 widget in one db
     And I should see 1 widget in another db

  Scenario: assume a clean db
    When I create a widget in one db
    Then I should see 1 widget in one db
     And I should see 0 widget in another db

  Scenario: assume a clean db
    When I create a widget in another db
    Then I should see 0 widget in one db
     And I should see 1 widget in another db

