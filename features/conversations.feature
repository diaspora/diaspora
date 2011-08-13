@javascript
Feature: private messages
    In order to be talkative
    As a User
    I want to converse with people

  Background:
    Given a user with username "bob"
    And a user named "Alice Awesome" with email "alice@alice.alice"
    When I sign in as "bob@bob.bob"
    And a user with username "bob" is connected with "Alice_Awesome"

    And I am on the conversations page

  Scenario: send a message
    Given I follow "New Message"
    And I wait for the ajax to finish
    And I fill in "contact_autocomplete" with "Alice" in the modal window
    And I press the first ".as-result-item" within ".as-results" in the modal window
    And I fill in "conversation_subject" with "Greetings" in the modal window
    And I fill in "conversation_text" with "hello, alice!" in the modal window
    And I press "Send" in the modal window
    And I wait for the ajax to finish
    Then I should see "Greetings" within "#conversation_inbox"
    And I should see "Greetings" within "#conversation_show"
    And "Alice Awesome" should be part of active conversation
    And I should see "hello, alice!" within ".stream"
