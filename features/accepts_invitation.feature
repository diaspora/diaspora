@javascript
Feature: invitation acceptance
    Scenario: accept invitation from admin
      Given I have been invited by an admin
      And I am on my acceptance form page
      And I fill in the following:
        | Username              | ohai           |
        | Email                 | woot@sweet.com |
        | user_password         | secret         |
        | Password confirmation | secret         |
      And I press "Sign up"
      Then I should be on the getting started page
      And I should see "getting_started_logo"
      And I fill in the following:
        | profile_first_name | O             |
        | profile_last_name  | Hai           |
        | tags               | #beingawesome |
      And I press "Save and continue"
      Then I should see "Profile updated"
			And I should see "Would you like to find your Facebook friends on Diaspora?"
      And I should not see "Here are the people who are waiting for you:"

    Scenario: accept invitation from user
      Given I have been invited by a user
      And I am on my acceptance form page
      And I fill in the following:
        | Username              | ohai           |
        | Email                 | woot@sweet.com |
        | user_password         | secret         |
        | Password confirmation | secret         |
      And I press "Sign up"
      Then I should be on the getting started page
      And I should see "getting_started_logo"
      And I fill in the following:
        | profile_first_name | O     |
        | profile_last_name  | Hai   |
        | tags               | #tags |
      And I press "Save and continue"
      Then I should see "Profile updated"
      
			And I should see "Would you like to find your Facebook friends on Diaspora?"

		When I follow "Skip"
		  Then I should be on the aspects page

