@javascript
Feature: new user registration

  Scenario: new user sees profile wizard
    When I go to the new user registration page
    And I fill in "Username" with "ohai"
    And I fill in "Email" with "ohai@example.com"
    And I fill in "user_password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And I press "Sign up"
    Then I should be on the getting started page
    And I should see "Welcome to Diaspora!"

    When I fill in "person_profile_first_name" with "O"
    And I fill in "person_profile_last_name" with "Hai"
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

    When I follow "Continue on to your everyone page, an overview of all of your aspects."
    Then I should be on the home page
    And I should see "We know you have friends, bring them to Diaspora!"

  @wip
  Scenario: new user can skip the profile wizard
    When I go to the new user registration page
    And I fill in "Username" with "ohai"
    And I fill in "Email" with "ohai@example.com"
    And I fill in "Password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And I press "Sign up"
    Then I should be on the getting started page
    And I should see "Welcome to Diaspora!"

    When I follow "skip getting started"
    Then I should be on the home page
    And I should see "We know you have friends, bring them to Diaspora!"
