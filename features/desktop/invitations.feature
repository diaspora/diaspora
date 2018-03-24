@javascript
Feature: Invitations
  Background:
    Given following users exist:
      | username    | email             |
      | Alice Smith | alice@alice.alice |

  Scenario: accept invitation from admin
    Given I have been invited by an admin
    And I am on my acceptance form page
    And I fill in the new user form
    And I press "Create account"
    Then I should be on the getting started page
    And I should see "Well, hello there!"
    And I fill in the following:
      | profile_first_name         | O             |

    And I confirm the alert after I follow "awesome_button"
    Then I should be on the stream page
    And I close the publisher

  Scenario: accept invitation from user
    Given I have been invited by "alice@alice.alice"
    And I am on my acceptance form page
    And I fill in the new user form
    And I press "Create account"
    Then I should be on the getting started page
    And I should see "Well, hello there!"
    And I should be able to friend "alice@alice.alice"
    And I fill in the following:
      | profile_first_name         | O             |

    And I confirm the alert after I follow "awesome_button"
    Then I should be on the stream page
    And I close the publisher
    And I log out
    And I sign in as "alice@alice.alice"
    And I click on "Invite your friends" navbar title
    And I click on selector ".invitations-button"
    Then I should see one less invite

  Scenario: sends an invitation from the sidebar
    When I sign in as "alice@alice.alice"
    And I click on "Invite your friends" navbar title
    And I click on selector ".invitations-button"
    And I fill in the following:
      | email_inviter_emails         | alex@example.com    |
    And I press "Send an invitation"
    Then I should see a flash message indicating success
    And I should have 1 Devise email delivery
    And I should not see "change your notification settings" in the last sent email

  Scenario: sends an invitation from the stream
    When I sign in as "alice@alice.alice"
    Then I should see "There are no posts to display here yet." within ".no-posts-info"
    When I press the first "a.invitations-link" within "#no_contacts"
    Then I should see "Invite someone to join diaspora*!" within "#invitationsModalLabel"
    And I fill in the following:
      | email_inviter_emails         | alex@example.com    |
    And I press "Send an invitation"
    Then I should see a flash message indicating success
    And I should have 1 Devise email delivery
    And I should see "You have been invited to join diaspora* by Alice Smith" in the last sent email
    And I should not see "change your notification settings" in the last sent email

  Scenario: sends an invitation from the people search page
    When I sign in as "alice@alice.alice"
    And I search for "test"
    Then I should see "Users matching test" within "#search_title"
    When I click on selector ".invitations-button"
    And I fill in the following:
      | email_inviter_emails         | alex@example.com    |
    And I press "Send an invitation"
    Then I should have 1 Devise email delivery
    And I should not see "change your notification settings" in the last sent email
