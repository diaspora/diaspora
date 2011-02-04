@javascript
Feature: invitation acceptance
    Scenario: accept invitation from admin
      Given I have been invited by an admin
      And I am on my acceptance form page
      And I fill in "Username" with "ohai"
      And I fill in "Email" with "woot@sweet.com"
      And I fill in "user_password" with "secret"
      And I fill in "Password confirmation" with "secret"
      And I press "Sign up"
      Then I should be on the getting started page
      And I should see "Welcome to Diaspora!"      
      And I should see "ohai"
     When I follow "Save and continue"
      And I fill in "profile_first_name" with "O"
      And I fill in "profile_last_name" with "Hai"
      And I fill in "profile_gender" with "guess!"
      And I press "Save and continue"
      Then I should see "Profile updated"
      And I should see "Your aspects"
      And I should not see "Here are the people who are waiting for you:"

    Scenario: accept invitation from user
      Given I have been invited by a user
      And I am on my acceptance form page
      And I fill in "Username" with "ohai"
      And I fill in "Email" with "sweet@woot.com"
      And I fill in "user_password" with "secret"
      And I fill in "Password confirmation" with "secret"
      And I press "Sign up"
      Then I should be on the getting started page
      And I should see "Welcome to Diaspora!"      
      And I should see "ohai"
     When I follow "Save and continue"
      And I fill in "profile_first_name" with "O"
      And I fill in "profile_last_name" with "Hai"
      And I fill in "profile_gender" with "guess!"
      And I press "Save and continue"
      Then I should see "Profile updated"
      
      And I should see "Your aspects"
      And I should see "Here are the people who are waiting for you:"

      And I press the first ".share_with.button"
      And I press the first ".add.button" within "#facebox #aspects_list ul > li:first-child"
      And I wait for the ajax to finish
      
     When I go to the home page
     Then I go to the aspects manage page
     Then I should see 1 contact in "Family"


