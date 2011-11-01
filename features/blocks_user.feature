@javascript
Feature: Blocking a user from the stream
  Background:
    Given a user with username "bob"
    And a user with username "alice"
    And a user with username "alice" is connected with "bob"

    When I sign in as "bob@bob.bob"
    And I post a status with the text "I am da #boss"
    And I am on the home page
    When I go to the destroy user session page


  Scenario: Blocking a user
    When I sign in as "alice@alice.alice"
    And I am on the home page
    Then I should see "I am da #boss"
    When I click on bob's block button
    And I am on the home page
    Then I should not see "I am da #boss"