Feature: database cleaning
  In order to ease example and feature writing
  As a developer
  I want to have my database in a clean state

  Scenario Outline: ruby app
    Given I am using <ORM>
    And the <Strategy> cleaning strategy

    When I run my scenarios that rely on a clean database
    Then I should see all green

  Examples:
    | ORM          | Strategy      |
    | ActiveRecord | transaction   |
    | ActiveRecord | truncation    |
    | ActiveRecord | deletion      |
    | DataMapper   | transaction   |
    | DataMapper   | truncation    |
    | MongoMapper  | truncation    |
    | Mongoid      | truncation    |
    | CouchPotato  | truncation    |
