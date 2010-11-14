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
    When I fill in "person_profile_first_name" with "O"
    And I fill in "person_profile_last_name" with "Hai"
    And I fill in "person_profile_gender" with "guess!"
    And I press "Save and continue"
    Then I should see "Profile updated"
    And I should see "Your aspects"

#  Not working with selenium - it thinks the aspect name field is hidden
#    When I fill in "Aspect name" with "cheez friends"
#    And I press "Add"
#    And show me the page
#    Then I should see "cheez friends"
    When I follow "Save and continue"
    Then I should see "Your services"

    When I follow "Save and continue"
    Then I should see "You're all set up, O!"
    And I should not see "skip getting started"

    When I follow "Continue on to your everyone page, an overview of all of your aspects."
    Then I should be on the aspects page
    And I should see "bring them to Diaspora!"

  Scenario: new user skips the setup wizard and returns to the setup wizard
    Given /^a user goes through the setup wizard$/
    When I go to getting_started
    Then I should not see "skip getting started"
  
  Scenario: new user skips the setup wizard
    When I follow "skip getting started"
    And I wait for the aspects page to load
    Then I should be on the aspects page
    And I should see "bring them to Diaspora!"
