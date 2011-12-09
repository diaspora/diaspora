@javascript
Feature: private messages
    In order to be talkative
    As a User
    I want to converse with people

  Background:
    Given a user with username "bob"
    And a user named "Alice Awesome" with email "alice@alice.alice"
    When I sign in as "bob@bob.bob"
    And a user with username "bob" is connected with "alice_awesome"

  Scenario: send a message
    Given I send a message with subject "Greetings" and text "hello, alice!" to "Alice Awesome"
    Then I should see "Greetings" within "#conversation_inbox"
    And I should see "Greetings" within "#conversation_show"
    And "Alice Awesome" should be part of active conversation
    And I should see "hello, alice!" within ".stream_container"
    When I sign in as "alice@alice.alice"
    And I reply with "hey, how you doing?"
    Then I should see "hey, how you doing?" within ".stream_container"

  Scenario: send an empty message
    When I send a message with subject "Empty Greetings" and text " " to "Alice Awesome"
    Then I should not see "Empty Greetings" within "#conversation_inbox"
