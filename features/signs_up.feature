@javascript
Feature: new user registration

  Background:
    When I go to the new user registration page
    And I fill in "user_username" with "ohai"
    And I fill in "user_email" with "ohai@example.com"
    And I fill in "user_password" with "secret"
    And I press "Continue"
    Then I should be on the getting started page
    And I should see "Well, hello there!"
    And I should see "Who are you?"
    And I should see "What are you into?"

  Scenario: new user goes through the setup wizard
    When I fill in the following:
      | profile_first_name | O             |
    And I preemptively confirm the alert
    And I follow "awesome_button"

    Then I should be on the stream page
    And I should not see "awesome_button"

  Scenario: new user skips the setup wizard
    When I preemptively confirm the alert
    And I follow "awesome_button"
    Then I should be on the stream page

  Scenario: closing a popover clears getting started
    When I preemptively confirm the alert
    And I follow "awesome_button"
    Then I should be on the stream page
    And I have turned off jQuery effects
    And I wait for the popovers to appear
    And I click close on all the popovers
    And I wait for 3 seconds
    And I go to the home page
    Then I should not see "Welcome to Diaspora"

  Scenario: user fills in bogus data - client side validation
    When I log out manually
    And I go to the new user registration page
    And I fill in "user_username" with "§$%&(/&%$&/=)(/"
    And I press "Continue"

    Then the "user_username" field should have a validation error
    And the "user_email" field should have a validation error
    And the "user_password" field should have a validation error

    When I fill in "user_username" with "valid_user"
    And I fill in "user_email" with "this is not a valid email $%&/()("
    And I press "Continue"

    Then the "user_email" field should have a validation error
    And the "user_password" field should have a validation error

    When I fill in "user_email" with "valid@email.com"
    And I fill in "user_password" with "1"
    And I press "Continue"

    Then the "user_password" field should have a validation error