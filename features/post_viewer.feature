@javascript
Feature: Post Viewer
  In order to make my content look really great
  As a User
  I want my posts to have a bunch of different templates that I can page through

  Background:
    Given a user with email "alice@alice.com"
    And I sign in as "alice@alice.com"

  Scenario: Paging through posts
    Given I have posts for each type of template
    Then I visit all of my posts
    And I should have seen all of my posts displayed with the correct template
