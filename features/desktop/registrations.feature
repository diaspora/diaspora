@javascript
Feature: New user registration
  In order to use Diaspora*
  As a desktop user
  I want to register an account

  Scenario: user signs up and goes to getting started
    Given I am on the new user registration page
    When I fill in the new user form
    And I press "Create account"
    Then I should be on the getting started page
    And I should see the 'getting started' contents

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
