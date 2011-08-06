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
      And I press "Create my account"
      Then I should be on the getting started page
      And I should see "Welcome"
      Then I follow "Edit Profile"
      And I fill in the following:
        | profile_first_name | O             |
        | profile_last_name  | Hai           |
        | tags               | #beingawesome |
        | profile_bio        | swagger       |
        | profile_location   | new york, ny  |
        | profile_gender     | diasporian    |
      And I press "Update Profile"
			And I should see "Welcome"
		  When I follow "Finished"
		  Then I should be on the aspects page

    Scenario: accept invitation from user
      Given I have been invited by a user
      And I am on my acceptance form page
      And I fill in the following:
        | Username              | ohai           |
        | Email                 | woot@sweet.com |
        | user_password         | secret         |
        | Password confirmation | secret         |
      And I press "Create my account"
      Then I should be on the getting started page
      And I should see "Welcome"
      Then I follow "Edit Profile"
      And I fill in the following:
        | profile_first_name | O             |
        | profile_last_name  | Hai           |
        | tags               | #beingawesome |
        | profile_bio        | swagger       |
        | profile_location   | new york, ny  |
        | profile_gender     | diasporian    |
      And I press "Update Profile"
			And I should see "Welcome"
		  When I follow "Finished"
		  Then I should be on the aspects page

