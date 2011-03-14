@javascript
Feature: posting
    In order to enlighten humanity for the good of society
    As a rock star
    I want to tell the world I am eating a yogurt
    
    Scenario: post to all aspects
      Given that I am a rock star
      And I have no open aspects saved
      Given I am signed in
        And I have an aspect called "Family"
        And I am on the home page
        And I expand the publisher
      When I fill in "status_message_fake_text" with "I am eating a yogurt"
        And I press "Share"
        And I follow "Home"
      Then I should see "I am eating a yogurt" within ".stream_element"

    Scenario: delete a post
      Given that I am a rock star
      And I have no open aspects saved
      And I am signed in
        And I have an aspect called "Family"
        And I am on the home page
        And I expand the publisher
      When I fill in "status_message_fake_text" with "I am eating a yogurt"
        And I press "Share"
        And I follow "Home"
        And I hover over the post
        And I preemptively confirm the alert
        And I click to delete the first post
        And I follow "Home"
        Then I should not see "I am eating a yogurt"

    Scenario Outline: post to one aspect
      Given that I am a rock star
      And I have no open aspects saved
      Given I am signed in
        And I have an aspect called "PostTo"
        And I have an aspect called "DidntPostTo"
        And I am on the home page
      When I follow "PostTo"
        And I wait for the ajax to finish
        And I expand the publisher
        And I fill in "status_message_fake_text" with "I am eating a yogurt"
        And I press "Share"
        And I follow "Home"
        And I follow "<aspect>"
      Then I should <see> "I am eating a yogurt"

      Examples:
        | aspect      | see     |
        | PostTo      | see     |
        | DidntPostTo | not see |
