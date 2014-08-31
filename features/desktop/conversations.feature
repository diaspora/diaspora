@javascript
Feature: private conversations
    In order to be talkative
    As a User
    I want to converse with people

  Background:
    Given a user named "Robert Grimm" with email "bob@bob.bob"
    And a user named "Alice Awesome" with email "alice@alice.alice"
    And a user with username "robert_grimm" is connected with "alice_awesome"
    When I sign in as "bob@bob.bob"

  Scenario: send a message
    Given I send a message with subject "Greetings" and text "hello, alice!" to "Alice Awesome"
    Then I should see "Greetings" within "#conversation_inbox"
    And I should see "Greetings" within "#conversation_show"
    And I should see "less than a minute ago" within "#conversation_inbox"
    And I should see "less than a minute ago" within "#conversation_show"
    And I should see "Alice Awesome" as a participant
    And "Alice Awesome" should be part of active conversation
    And I should see "hello, alice!" within ".stream_container"
    When I sign in as "alice@alice.alice"
    And I reply with "hey, how you doing?"
    Then I should see "hey, how you doing?" within ".stream_container"
