@javascript
Feature: New user registration
  In order to use Diaspora*
  As a desktop user
  I want to register an account

  Scenario: user signs up, goes to getting started and receives a welcome email verifying their address
    Given the podmin contact address is "podmin@example.org"
    And the podmin welcome message is "Welcome to my little pod!"
    And I am on the new user registration page
    When I fill in the new user form
    And I press "Create account"
    Then I should be on the getting started page
    And I should see the 'getting started' contents
    And I should have 1 email delivery
    And "ohai@example.com" should have received an email with subject "Welcome to the diaspora* community!"
    And I should see "ohai" in the last sent email
    And I should see "Welcome to my little pod!" in the last sent email
    And the last sent email should have a plain text and an HTML part
    And the last sent email should have the reply-to address "podmin@example.org"
    And my email address should not be verified
    When I follow the "Verify my email address" link from the last sent email
    Then my email address should be verified

  Scenario: with mandatory email verification, a new user cannot use the pod until they verify
    Given the podmin requires email verification
    And I am on the new user registration page
    When I fill in the new user form
    And I press "Create account"
    And I go to the stream page
    Then I should be on the verify email page
    When I press "Resend verification email"
    Then I should see "Verification email sent"
    And I should have 2 email delivery
    When I follow the "Verify my email address" link from the last sent email
    And I go to the stream page
    Then I should be on the stream page

  Scenario: registrations are closed, user is informed
    Given the registrations are closed
    When I am on the new user registration page
    Then I should see "Open signups are closed at this time"

  Scenario: User is unable to register even by manually sending the POST request
    Given I am on the new user registration page
    When I fill in the new user form
    Given the registrations are closed
    When I press "Create account"
    Then I should see "Open signups are closed at this time"
