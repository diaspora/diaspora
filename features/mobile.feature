@javascript
Feature: Navigate mobile site

  In order to navigate Diaspora*
  As a mobile user
  I want to show mobile site of Diaspora*

  Scenario: Show mobile site
    Given I am in a mobile browser
    And I visit the home page 
    Then I should see "sign in"
