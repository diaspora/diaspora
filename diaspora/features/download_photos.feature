@wip
@javascript
Feature: Download Photos

  Scenario: Download my photos
  	Given I am signed in
    And I click on my name in the header
    And I follow "settings"
    Then I should be on my account settings page
    And I follow "download my photos"
    Then I should get download alert
