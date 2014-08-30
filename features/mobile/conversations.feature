@javascript
Feature: private conversations mobile
    In order to be talkative
    As a mobile user
    I want to converse with people

  Background:
    Given a user with username "bob"
    And a user named "Alice Awesome" with email "alice@alice.alice"
    And a user with username "bob" is connected with "alice_awesome"
    When I toggle the mobile view
    And I sign in as "bob@bob.bob"

  Scenario: send and delete a mobile message
    Given I send a mobile message with subject "Greetings" and text "hello, alice!" to "Alice Awesome"
    Then I should see "Greetings" within ".ltr"
    And I should see "Greetings" within ".ltr"
    And I press the first ".ltr" within ".conversation"
    And "Alice Awesome" should be part of active conversation
    And I should see "hello, alice!" within ".stream_element"
    When I sign in as "alice@alice.alice"
    And I reply with "hey, how you doing?"
    And I press the first ".ltr" within ".conversation"
    Then I should see "hey, how you doing?"
    When I click on selector "a.remove"
    And I confirm the alert
    Then I should not see "hey, how you doing"
