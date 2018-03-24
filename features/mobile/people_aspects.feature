@javascript @mobile
Feature: adding and removing people from aspects
  In order to add people to my contacts
  As a mobile user
  I want to add and remove people from my contacts

  Background:
    Given following users exist:
      | username   |
      | bob        |
      | alice      |
    And I sign in as "bob@bob.bob" on the mobile website

  Scenario: verify different states of the cover button
    When I am on "alice@alice.alice"'s page
    Then the aspect dropdown within "#author_info" should be labeled "Add contact"

    When I select "Unicorns" from "user_aspects" within "#author_info"
    Then the aspect dropdown within "#author_info" should be labeled "Unicorns"

    When I select "Besties" from "user_aspects" within "#author_info"
    Then the aspect dropdown within "#author_info" should be labeled "In 2 aspects"

  Scenario: add contact to aspect
    When I am on "alice@alice.alice"'s page
    And I select "Unicorns" from "user_aspects" within "#author_info"
    Then the aspect dropdown within "#author_info" should be labeled "Unicorns"
    Then I should have 1 contacts in "Unicorns"

  Scenario: remove contact to aspect
    When I am on "alice@alice.alice"'s page
    And I select "Unicorns" from "user_aspects" within "#author_info"
    Then the aspect dropdown within "#author_info" should be labeled "Unicorns"

    And I select "Besties" from "user_aspects" within "#author_info"
    Then the aspect dropdown within "#author_info" should be labeled "In 2 aspects"
    Then I should have 1 contacts in "Unicorns"

    When I am on "alice@alice.alice"'s page
    And I select "Unicorns" from "user_aspects" within "#author_info"
    Then the aspect dropdown within "#author_info" should be labeled "Besties"
    Then I should have 0 contacts in "Unicorns"
