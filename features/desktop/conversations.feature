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
    Then I should see "Greetings" within "#conversation-inbox"
    And I should see "Greetings" within "#conversation-show"
    And I should see "less than a minute ago" within "#conversation-inbox"
    And I should see "less than a minute ago" within "#conversation-show"
    And I should see "Alice Awesome" as a participant
    And "Alice Awesome" should be part of active conversation
    And I should see "hello, alice!" within ".stream-container"
    When I sign in as "alice@alice.alice"
    Then I should have 1 unread private message
    And I should have 1 email delivery
    When I reply with "hey, how you doing?"
    Then I should see "hey, how you doing?" within ".stream-container"

  Scenario: send a message using keyboard shortcuts
    When I sign in as "bob@bob.bob"
    And I send a message with subject "Greetings" and text "hello, alice!" to "Alice Awesome" using keyboard shortcuts
    Then I should see "Greetings" within "#conversation-inbox"
    And I should see "Greetings" within "#conversation-show"
    And "Alice Awesome" should be part of active conversation
    And I should see "hello, alice!" within ".stream-container"
    When I reply with "hey, how you doing?" using keyboard shortcuts
    Then I should see "hey, how you doing?" within ".stream-container"
    When I sign in as "alice@alice.alice"
    Then I should have 2 unread private messages
    And I should have 2 email delivery

  Scenario: send a message from the profile page
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I click on selector "#message_button"
    And I fill in "conversation-subject" with "Greetings"
    And I fill in "new-message-text" with "hello, alice!"
    And I press "Send" within "#conversationModal"
    Then I should see "Greetings" within "#conversation-inbox"
    And I should see "Greetings" within "#conversation-show"
    And "Alice Awesome" should be part of active conversation
    And I should see "hello, alice!" within ".stream-container"

  Scenario: delete a conversation
    When I sign in as "bob@bob.bob"
    And I send a message with subject "Greetings" and text "hello, alice!" to "Alice Awesome"
    Then I should see "Greetings" within "#conversation-inbox"
    When I click on selector ".hide_conversation"
    Then I should not see "Greetings" within "#conversation-inbox"
    When I sign in as "alice@alice.alice"
    Then I should have 1 unread private message
    And I should have 1 email delivery
    When I reply with "hey, how you doing?"
    Then I should see "hey, how you doing?" within ".stream-container"
    When I sign in as "bob@bob.bob"
    Then I should have 1 email delivery
    And I should have no unread private messages
