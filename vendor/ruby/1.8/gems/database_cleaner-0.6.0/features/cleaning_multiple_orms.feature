Feature: database cleaning using multiple ORMs
  In order to ease example and feature writing
  As a developer
  I want to have my database in a clean state

  Scenario Outline: ruby app
    Given I am using <ORM1> and <ORM2>

    When I run my scenarios that rely on clean databases using multiple orms
    Then I should see all green

  Examples:
    | ORM1         | ORM2         |
    | ActiveRecord | DataMapper   |
    | ActiveRecord | MongoMapper  |
    | ActiveRecord | Mongoid      |
    | ActiveRecord | CouchPotato  |
    | DataMapper   | ActiveRecord |
    | DataMapper   | MongoMapper  |
    | DataMapper   | Mongoid      |
    | DataMapper   | CouchPotato  |
    | MongoMapper  | ActiveRecord |
    | MongoMapper  | DataMapper   |
    | MongoMapper  | Mongoid      |
    | MongoMapper  | CouchPotato  |
    | CouchPotato  | ActiveRecord |
    | CouchPotato  | DataMapper   |
    | CouchPotato  | MongoMapper  |
    | CouchPotato  | Mongoid      |
