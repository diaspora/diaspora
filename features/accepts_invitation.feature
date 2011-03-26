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
      And I should see "getting_started_logo"
     When I fill in "profile_first_name" with "O"
      And I fill in "profile_last_name" with "Hai"
      And I fill in "profile_tag_string" with "#beingawesome"
      And I press "Save and continue"
      Then I should see "Profile updated"
			And I should see "Would you like to find your Facebook friends on Diaspora?"
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
      And I should see "getting_started_logo"
     When I fill in "profile_first_name" with "O"
      And I fill in "profile_last_name" with "Hai"
      And I fill in "profile_tag_string" with "#tags"
      And I press "Save and continue"
      Then I should see "Profile updated"
      
			And I should see "Would you like to find your Facebook friends on Diaspora?"

		When I follow "Skip"
		  Then I should see "People already on Diaspora"

      And I press the first ".share_with.button"
      And I press the first ".add.button" within "#facebox #aspects_list ul > li:first-child"
      And I wait for the ajax to finish
      
     When I go to the home page
     Then I go to the manage aspects page
     Then I should see 1 contact in "Family"


