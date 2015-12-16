@javascript
Feature: private conversations
    In order to be talkative
    As a User
    I want to converse with people

  Background:
    Given a user named "Robert Grimm" with email "bob@bob.bob"
    And a user named "Alice Awesome" with email "alice@alice.alice"
    And a user with username "robert_grimm" is connected with "alice_awesome"

  Scenario: open the conversations page without any contacts
    Given a user with email "eve@eve.eve"
    When I sign in as "eve@eve.eve"
    And I am on the conversations page
    Then I should see "You need to add some contacts before you can start a conversation"

  Scenario: send a message
    When I sign in as "bob@bob.bob"
    And I send a message with subject "Greetings" and text "hello, alice!" to "Alice Awesome"
    Then I should see "Greetings" within "#conversation_inbox"
    And I should see "Greetings" within "#conversation_show"
    And I should see "less than a minute ago" within "#conversation_inbox"
    And I should see "less than a minute ago" within "#conversation_show"
    And I should see "Alice Awesome" as a participant
    And "Alice Awesome" should be part of active conversation
    And I should see "hello, alice!" within ".stream_container"
    When I sign in as "alice@alice.alice"
    Then I should have 1 unread private message
    And I should have 1 email delivery
    When I reply with "hey, how you doing?"
    Then I should see "hey, how you doing?" within ".stream_container"

  Scenario: send a message using keyboard shortcuts
    When I sign in as "bob@bob.bob"
    And I send a message with subject "Greetings" and text "hello, alice!" to "Alice Awesome" using keyboard shortcuts
    Then I should see "Greetings" within "#conversation_inbox"
    And I should see "Greetings" within "#conversation_show"
    And "Alice Awesome" should be part of active conversation
    And I should see "hello, alice!" within ".stream_container"
    When I reply with "hey, how you doing?" using keyboard shortcuts
    Then I should see "hey, how you doing?" within ".stream_container"
    When I sign in as "alice@alice.alice"
    Then I should have 2 unread private messages
    And I should have 2 email delivery
