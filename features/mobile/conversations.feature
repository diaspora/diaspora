@javascript @mobile
Feature: private conversations mobile
    In order to be talkative
    As a mobile user
    I want to converse with people

  Background:
    Given a user with username "bob"
    And a user named "Alice Awesome" with email "alice@alice.alice"
    And a user with username "bob" is connected with "alice_awesome"
    And I sign in as "bob@bob.bob" on the mobile website

  Scenario: send and delete a mobile message
    Given I send a mobile message with subject "Greetings" and text "hello, alice!" to "Alice Awesome"
    Then I should see "Greetings" within ".conversation h3"
    And "Alice Awesome" should be part of active conversation
    And I should see "hello, alice!" within ".stream-element"
    When I sign in as "alice@alice.alice" on the mobile website
    And I reply with "hey, how you doing?"
    And I press the first ".ltr" within ".conversation"
    Then I should see "hey, how you doing?"
    When I confirm the alert after I click on selector "a.remove"
    Then I should not see "hey, how you doing"
