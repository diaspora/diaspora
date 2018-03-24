@javascript
Feature: Download Photos

  Scenario: Request my photos
    Given I am signed in
    When I click on my name in the header
    When I follow "Settings"
    Then I should be on my account settings page
    When I follow "Request my photos"
    Then I should see a flash message indicating success
    And I should see a flash message containing "We are currently processing your photos"

  Scenario: Refresh my photos
    Given I am signed in
    When I did request my photos
    And I click on my name in the header
    When I follow "Settings"
    Then I should be on my account settings page
    When I follow "Refresh my photos"
    Then I should see a flash message indicating success
    And I should see a flash message containing "We are currently processing your photos"

  Scenario: Download my photos
    Given I am signed in
    When I did request my photos
    And I click on my name in the header
    When I follow "Settings"
    Then I should be on my account settings page
    When I follow "Download my photos"
    Then I should get a zipped file
