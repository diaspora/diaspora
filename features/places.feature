@javascript
Feature: Interacting with Places

  Background:
    Given there is a place called "McDonald's in Colima" 
    And I am signed in
    And I am on the place page called "McDonald's in Colima" 

  Scenario: Writing a review
    When I post a review with the text "This place is awesome"
    Then I should be on the site page for "McDonald's in Colima"
    And I should see "Samuel Beckett"


