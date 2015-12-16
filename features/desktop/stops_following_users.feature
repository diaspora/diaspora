@javascript
Feature: Unfollowing
  In order to stop seeing updates from self-important rockstars
  As a user
  I want to be able to stop following people

  Background:
    Given following users:
		| email             |
		| bob@bob.bob       |
		| alice@alice.alice |
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I add the person to my "Besties" aspect

  Scenario: stop following someone while on their profile page
    When I am on "alice@alice.alice"'s page
    And I remove the person from my "Besties" aspect
    And I go to the home page
    Then I should have 0 contacts in "Besties"

    When I sign out
    And I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    Then I should not see "is sharing with you."

  Scenario: stop following someone while on the contacts page
    When I go to the contacts page
    And I follow "Besties"
    And I remove the first person from the aspect
    And I follow "My contacts"
    Then I should have 0 contacts in "Besties"

    When I sign out
    And I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    Then I should not see "is sharing with you."
