@javascript
Feature: Change password

  Scenario: Change my password
    Given I am signed in
    When I go to the users edit page
    And I fill out change password section with my password and "newsecret" and "newsecret"
    And I press "Change password"
    Then I should see "Password changed"
    Then I should be on the new user session page
    When I sign in with password "newsecret"
    Then I should be on the stream page

  Scenario: Reset my password
    Given a user with email "forgetful@users.net"
    Given I am on forgot password page
    When I fill out forgot password form with "Forgetful@users.net"
    And I submit forgot password form
    Then I should see "You will receive an email with instructions"
    When I follow the "Change my password" link from the last sent email
    Then I should see "Change my password"
    When I fill out reset password form with "supersecret" and "supersecret"
    And I submit reset password form
    Then I should be on the stream page
