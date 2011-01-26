Feature: posting
    In order to enlighten humanity for the good of society
    As a rock star
    I want to tell the world I am eating a yogurt
    
    Scenario: post to all aspects
      Given I am signed in
        And I have an aspect called "Family"
        And I am on the home page
      When I fill in "status_message_message" with "I am eating a yogurt"
        And I press "Share"
        
        And I am on the home page
      Then I should see "I am eating a yogurt" within ".stream_element"

    @javascript
    Scenario: delete a post
      Given I am signed in
        And I have an aspect called "Family"
        And I am on the home page
        And I expand the publisher
      When I fill in "status_message_message" with "I am eating a yogurt"
        And I press "Share"
        And I am on the home page
        And I hover over the post
        And I preemptively confirm the alert
        And I press the first ".delete" within ".stream_element"
        And I am on the home page
        Then I should not see "I am eating a yoghurt"

      
    Scenario Outline: post to one aspect
      Given I am signed in
        And I have an aspect called "PostTo"
        And I have an aspect called "DidntPostTo"
        And I am on the home page
      When I follow "PostTo"
        And I fill in "status_message_message" with "I am eating a yogurt"
        And I press "Share"
        
        And I follow "<aspect>"
      Then I should <see> "I am eating a yogurt"
      
      Examples:
        | aspect      | see     |
        | PostTo      | see     |
        | DidntPostTo | not see |
