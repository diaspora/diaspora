@javascript @mobile
Feature: Invitations

  Scenario: Accepting an invitation
    When I visit alice's invitation code url
    When I fill in the new user form
    And I press "Create my account!"
    Then I should see the "welcome to diaspora" message
    And I should be able to friend Alice
