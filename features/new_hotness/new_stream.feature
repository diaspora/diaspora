@javascript
Feature: Interacting with the stream
  Background:
    Given I am logged in as a beta user with email "bill@bill.com"
    And "bill@bill.com" is an admin
    And I make a new publisher post "I like it like that."
    And I make a new publisher post "yeah baby."
    And I make a new publisher post "I got soul."
    When I go to the new stream

  Scenario: Visiting the stream
    Then "I got soul." should be frame 1
    Then "yeah baby." should be frame 2
    Then "I like it like that." should be frame 3

#  Scenario: Clicking on a post show the interactions
#    And I wait for 5 seconds
#    When I click into the "I got soul." stream frame
#    And I make a show page comment "you're such a pip"
#    And I go to the new stream
#    When I click the "I got soul." stream frame
#    Then "you're such a pip" should be a comment for "I got soul."