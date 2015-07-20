@javascript
Feature: Change email

  Scenario: Change my email
    Given I am signed in
    When I go to the users edit page
    And I fill in the following:
      | user_email         | new_email@newplac.es           |
    And I press "Change email"
    Then I should see "Email changed"
    And I follow the "confirm_email" link from the last sent email
    Then I should see "activated"
    And my "email" should be "new_email@newplac.es"

  Scenario: Change my email preferences
    Given I am signed in
    When I go to the users edit page
    And I uncheck "user_email_preferences_mentioned"
    And I press "change_email_preferences"
    Then I should see "Email notifications changed"
    And the "user_email_preferences_mentioned" checkbox should not be checked
