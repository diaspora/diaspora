@javascript
Feature: new user registration

  Background:
    When I go to the new user registration page
    And I fill in "Username" with "ohai"
    And I fill in "Email" with "ohai@example.com"
    And I fill in "user_password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And I press "Sign up"
    Then I should be on the getting started page
    And I should see "getting_started_logo"

  Scenario: new user goes through the setup wizard
   When I fill in "profile_first_name" with "O"
    And I fill in "profile_last_name" with "Hai"
    And I fill in "profile_gender" with "guess!"
    And I press "Save and continue"
    And I wait for "step 2" to load
    Then I should see "Profile updated"
    And I should see "Would you like to find your Facebook friends on Diaspora?"
    And I follow "Skip"

    Then I should be on the aspects page
    And I should not see "skip getting started"
    And I should see "Bring the people that matter in your life to Diaspora!"

  Scenario: new user skips the setup wizard and returns to the setup wizard
    When I follow "skip getting started"
    And I go to the getting started page
    Then I should not see "skip getting started"
  
  Scenario: new user skips the setup wizard
    When I follow "skip getting started"
    And I wait for "the aspects page" to load
    Then I should be on the aspects page
    And I should see "Bring the people that matter in your life to Diaspora!"
