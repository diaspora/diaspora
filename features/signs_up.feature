@javascript
Feature: new user registration

  Background:
    When I go to the new user registration page
    And I fill in "user_username" with "ohai"
    And I fill in "user_email" with "ohai@example.com"
    And I fill in "user_password" with "secret"
    And I fill in "user_password_confirmation" with "secret"
    And I press "Create my account"
    Then I should be on the getting started page
    And I should see "Welcome"
    And I should see "Fill out your profile"
    And I should see "Connect to your other social networks"
    And I should see "Connect with cool people"
    And I should see "Follow your interests"
    And I should see "Connect to Cubbi.es"

  Scenario: new user goes through the setup wizard
   When I follow Edit Profile in the same window
    And I fill in "profile_first_name" with "O"
    And I fill in "profile_last_name" with "Hai"
    And I fill in "tags" with "#tags"
    And I press "Update Profile"
    And I wait for the ajax to finish
    Then I should see "O Hai" within "#user_menu"
    And I should see "Welcome"
    And I follow "Finished"

    Then I should be on the aspects page
    And I should not see "Finished"

  Scenario: new user skips the setup wizard
    When I follow "Finished"
    Then I should be on the aspects page
