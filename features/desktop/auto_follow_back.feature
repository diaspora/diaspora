@javascript
Feature: auto follow back a user

  Background:
    Given following users exist:
      | username       | email             |
      | Bob Jones      | bob@bob.bob       |
      | Alice Smith    | alice@alice.alice |
    And I sign in as "bob@bob.bob"
    And I have an aspect called "My main aspect"
    And I have an aspect called "Others" with auto follow back
    And I sign out

  Scenario: When a user with auto follow back enabled is shared with, he's sharing back
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    And I add the person to my "Besties" aspect
    And I sign out
    And I sign in as "bob@bob.bob"
    Then I should have 1 contact in "Others"
    When I am on "alice@alice.alice"'s page
    Then I should see "Others" within the contact aspect dropdown

  Scenario: When a user with auto follow back enabled is shared with by a user he's ignoring, he's not sharing back
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I click on the profile block button
    And I sign out
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    And I add the person to my "Besties" aspect
    And I sign out
    And I sign in as "bob@bob.bob"
    Then I should have 0 contact in "Others"
    When I am on "alice@alice.alice"'s page
    Then I should see "Stop ignoring" within "#unblock_user_button"
