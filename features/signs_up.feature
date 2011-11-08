@javascript
Feature: new user registration

  Background:
    When I go to the new user registration page
    And I fill in "user_username" with "ohai"
    And I fill in "user_email" with "ohai@example.com"
    And I fill in "user_password" with "secret"
    And I fill in "user_password_confirmation" with "secret"
    And I press "Create my account!"
    Then I should be on the getting started page
    And I should see "Well, hello there!"
    And I should see "Who are you?"
    And I should see "What are you into?"

  Scenario: new user goes through the setup wizard
    When I fill in the following:
      | profile_first_name | O             |
    And I preemptively confirm the alert
    And I follow "awesome_button"

    Then I should be on the multi page
    And I should not see "awesome_button"

  Scenario: new user skips the setup wizard
    When I preemptively confirm the alert
    And I follow "awesome_button"
    Then I should be on the multi page

  Scenario: closing a popover clears getting started
    When I preemptively confirm the alert
    And I follow "awesome_button"
    Then I should be on the multi page
    And I have turned off jQuery effects
    And I wait for the popovers to appear
    And I click close on all the popovers
    And I wait for 3 seconds
    And I go to the home page
    Then I should not see "Welcome to Diaspora"
