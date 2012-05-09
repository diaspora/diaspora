@javascript
Feature: Invitations

  Scenario: Accepting an invitation
    When I visit alice's invitation code url
    # Then I should see the "alice is excited" message
    When I fill in the new user form
    And I press "Continue"
    Then I should see the "welcome to diaspora" message
    And I should be able to friend Alice
