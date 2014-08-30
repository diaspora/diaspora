@javascript
Feature: New user registration
  In order to use Diaspora*
  As a mobile user
  I want to register an account

  Background:
    Given I toggle the mobile view
    And I am on the login page
	And I follow "Sign up"

  Scenario: user signs up and goes to getting started
	When I fill in the new user form
    And I submit the form
    Then I should be on the getting started page
    Then I should see the 'getting started' contents

  Scenario: user fills in bogus data - client side validation
    When I fill in the following:
        | user_username        | $%&(/&%$&/=)(/    |
    And I submit the form
    Then I should not be able to sign up

    When I fill in the following:
        | user_username     | valid_user                        |
        | user_email        | this is not a valid email $%&/()( |
    And I submit the form
    Then I should not be able to sign up

    When I fill in the following:
        | user_email        | valid@email.com        |
        | user_password     | 1                      |
    And I submit the form
    Then I should not be able to sign up
