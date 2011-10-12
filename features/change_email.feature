@javascript
Feature: Change email

  Scenario: Change my email
  	Given I am signed in
    And I click on my name in the header
    And I follow "Settings"
    Then I should be on my account settings page
    When I fill in "user_email" with "new_email@newplac.es"
    And I press "Change email"
    Then I should see "Email changed"
    And I follow the "confirm_email" link from the last sent email
    Then I should see "activated"
    And my "email" should be "new_email@newplac.es"
