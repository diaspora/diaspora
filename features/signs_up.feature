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
    And I should see "Welcome to Diaspora!"

  Scenario: new user goes through the setup wizard
    Then I should see "Your services"
    When I follow "Save and continue"
    And I wait for "step 2" to load

    When I fill in "profile_first_name" with "O"
    And I fill in "profile_last_name" with "Hai"
    And I fill in "profile_gender" with "guess!"
    And I press "Save and continue"
    And I wait for "step 3" to load
    Then I should see "Profile updated"
    And I should see "Your aspects"
    
    When I fill in "step-3-aspect-name" with "cheez friends"
    And I press "Add"
    Then I should see "cheez friends"

    When I follow "Save and continue"
    And I wait for "step 4" to load
    Then I should see "You're all set up, O!"
    But I should not see "skip getting started"

    When I follow "Continue on to your Home page, an overview of all of your aspects."
    Then I should be on the aspects page
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
