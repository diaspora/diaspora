@javascript
Feature: Change password

  Scenario: Change my password
    Given I am signed in
    When I go to the edit user page
    And I fill out change password section with my password and "newsecret" and "newsecret"
    And I press "Change password"
    Then I should see "Password changed"
    Then I should be on the new user session page
    When I sign in with password "newsecret"
    Then I should be on the stream page

  Scenario: Attempt to change my password with invalid input
    Given I am signed in
    When I go to the edit user page
    And I fill out change password section with my password and "too" and "short"
    And I press "Change password"
    Then I should see "Password change failed"
    And I should see "Password is too short"
    And I should see "Password confirmation doesn't match"

  Scenario: Reset my password
    Given a user named "Georges Abitbol" with email "forgetful@users.net"
    Given I am on forgot password page
    When I fill out forgot password form with "forgetful@users.net"
    And I submit forgot password form
    Then I should see "If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes."
    When I follow the "Change my password" link from the last sent email
    When I fill out the password reset form with "supersecret" and "supersecret"
    And I submit the password reset form
    Then I should be on the new user session page
    And I sign in manually as "georges_abitbol" with password "supersecret"
    Then I should be on the stream page

  Scenario: Attempt to reset password with invalid password
    Given a user named "Georges Abitbol" with email "forgetful@users.net"
    Given I am on forgot password page
    When I fill out forgot password form with "forgetful@users.net"
    And I submit forgot password form
    When I follow the "Change my password" link from the last sent email
    When I fill out the password reset form with "too" and "short"
    And I press "Change my password"
    Then I should be on the user password page
    And I should see "Password is too short"
    And I should see "Password confirmation doesn't match"

  Scenario: Attempt to reset password with invalid email
    Given I am on forgot password page
    When I fill out forgot password form with "notanemail"
    And I submit forgot password form
    Then I should see "If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes."
