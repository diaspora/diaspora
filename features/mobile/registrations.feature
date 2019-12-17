@javascript @mobile
Feature: New user registration
  In order to use Diaspora*
  As a mobile user
  I want to register an account

  Background:
    Given I am on the new user registration page

  Scenario: user signs up and goes to getting started
    When I fill in the new user form
    And I press "Create account"
    Then I should be on the getting started page
    And I should see the 'getting started' contents

  Scenario: user fills in bogus data - client side validation
    When I fill in the following:
        | user_username        | $%&(/&%$&/=)(/    |
    And I press "Create account"
    Then I should not be able to sign up
    And I should have a validation error on "user_username, user_password, user_email"

    When I fill in the following:
        | user_username     | valid_user                        |
        | user_email        | this is not a valid email $%&/()( |
    And I press "Create account"
    Then I should not be able to sign up
    And I should have a validation error on "user_password, user_email"

    When I fill in the following:
        | user_email        | valid@email.com        |
        | user_password     | 1                      |
    And I press "Create account"
    Then I should not be able to sign up
    And I should have a validation error on "user_password, user_password_confirmation"
