@javascript
Feature: Change password

  Scenario: Change my password
    Given I am signed in
    When I go to the users edit page
    And I put in my password in "user_current_password"
    And I fill in "user_password" with "newsecret"
    And I fill in "user_password_confirmation" with "newsecret"
    And I press "Change password"
    Then I should see "Password changed"
    Then I should be on the new user session page
    When I sign in with password "newsecret"
    Then I should be on the explore page

  Scenario: Reset my password
    Given a user with email "forgetful@users.net"
    Given I am on the new user password page
    And I fill in "Email" with "Forgetful@users.net"
    And I press "Send me reset password instructions"
    Then I should see "You will receive an email with instructions"
    And I follow the "Change my password" link from the last sent email
    Then I should see "Change your password"
    And I fill in "Password" with "supersecret"
    And I fill in "Password confirmation" with "supersecret"
    And I press "Change my password"
    Then I should see "Your password was changed successfully"
