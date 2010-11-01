Feature: new user registration

  Scenario: new user sees profile wizard
    When I go to the new user registration page
    And I fill in "Username" with "ohai"
    And I fill in "Email" with "ohai@example.com"
    And I fill in "Password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And I press "Sign up"
    Then I should be on the getting started page
    And I should see "Welcome to Diaspora!"

    When I fill in "person_profile_first_name" with "O"
    And I fill in "person_profile_last_name" with "Hai"
    And I press "Save and continue"
    Then I should see "Profile updated"
    And I should see "Your aspects"


