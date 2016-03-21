@javascript @mobile
Feature: Invitations
  Background:
    Given following users exist:
      | username    | email             |
      | Alice Smith | alice@alice.alice |

  Scenario: Accepting an invitation
    Given I have been invited by "alice@alice.alice"
    And I am on my acceptance form page
    When I fill in the new user form
    And I press "Sign up"
    Then I should see the "welcome to diaspora" message
    And I should be able to friend "alice@alice.alice"
