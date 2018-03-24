@javascript @mobile
Feature: Change password
  As a mobile user
  I want to Change my password


  Scenario: Change my password
    Given I am signed in on the mobile website
    When I go to the edit user page
    And I fill out change password section with my password and "newsecret" and "newsecret"
    And I press "Change password"
    Then I should see "Password changed"
    And I should be on the new user session page
    When I sign in with password "newsecret" on the mobile website
    Then I should be on the stream page

  Scenario: Attempt to change my password with invalid input
    Given I am signed in on the mobile website
    When I go to the edit user page
    And I fill out change password section with my password and "too" and "short"
    And I press "Change password"
    Then I should see "Password is too short"
    And I should see "Password confirmation doesn't match"

  Scenario: Reset my password
    Given a user named "Georges Abitbol" with email "forgetful@users.net"
    And I am on forgot password page
    When I fill out forgot password form with "forgetful@users.net"
    And I submit forgot password form
    Then I should see "You will receive an email with instructions"
    When I follow the "Change my password" link from the last sent email
    And I fill out the password reset form with "supersecret" and "supersecret"
    And I submit the password reset form
    Then I should be on the stream page
    When I sign out
    And I go to the login page
    And I sign in manually as "georges_abitbol" with password "supersecret" on the mobile website
    Then I should be on the stream page

  Scenario: Attempt to reset password with invalid password
    Given a user named "Georges Abitbol" with email "forgetful@users.net"
    And I am on forgot password page
    When I fill out forgot password form with "forgetful@users.net"
    And I submit forgot password form
    And I follow the "Change my password" link from the last sent email
    And I fill out the password reset form with "too" and "short"
    And I press "Change my password"
    Then I should be on the user password page
    And I should see "Password is too short"
    And I should see "Password confirmation doesn't match"

  Scenario: Attempt to reset password with invalid email
    Given I am on forgot password page
    When I fill out forgot password form with "notanemail"
    And I submit forgot password form
    Then I should see "No account with this email exists"
