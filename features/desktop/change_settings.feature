@javascript
Feature: Change settings

  Background:
    Given I am signed in
    And I have following aspects:
      | Friends    |
      | Family     |
    When I go to the edit user page

  Scenario: Change my email
    When I fill in the following:
      | user_email         | new_email@newplac.es           |
    And I press "Change email"
    Then I should see "Email changed"
    And I follow the "confirm_email" link from the last sent email
    Then I should see "activated"
    And my "email" should be "new_email@newplac.es"

  Scenario: Change my email preferences
    When I uncheck "user_email_preferences_mentioned"
    And I press "change_email_preferences"
    Then I should see "Email notifications changed"
    And the "user_email_preferences_mentioned" checkbox should not be checked
    When I uncheck "user_email_preferences_mentioned_in_comment"
    And I press "change_email_preferences"
    Then I should see "Email notifications changed"
    And the "user_email_preferences_mentioned_in_comment" checkbox should not be checked

  Scenario: Change my preferred language
    When I select "polski" from "user_language"
    And I press "Change language"
    Then I should see "Język został zmieniony"
    And "polski" should be selected from "user_language"

  Scenario: Change my post default aspects
    When I go to the stream page
    And I expand the publisher
    Then I should see "All aspects" within ".aspect-dropdown"
    When I go to the edit user page
    And I press the aspect dropdown
    And I toggle the aspect "Family"
    And I press the aspect dropdown
    And I press "Change" within "#post-default-aspects"
    And I go to the stream page
    And I expand the publisher
    Then I should see "Family" within ".aspect-dropdown"

  Scenario: Change my post default to public
    When I press the aspect dropdown
    And I toggle the aspect "Public"
    And I press "Change" within "#post-default-aspects"
    And I go to the stream page
    And I expand the publisher
    Then I should see "Public" within ".aspect-dropdown"

  Scenario: exporting profile data
    When I click on the first selector "#account_data a"
    Then I should see "Download my profile"
    And I should have 1 email delivery
