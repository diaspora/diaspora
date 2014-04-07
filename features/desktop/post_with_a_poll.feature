@javascript
Feature: posting with a poll

    Background:
      Given following users exist:
        | username   |
        | bob        |
      And I sign in as "bob@bob.bob"
      And I am on the home page
      
    Scenario: expanding the publisher
      Given "#publisher-poll-creator" is hidden
      When I expand the publisher
      Then I should see an element "#poll_creator"

    Scenario: expanding the poll creator
      Given "#publisher-poll-creator" is hidden
      When I expand the publisher
      And I press the element "#poll_creator"
      Then I should see an element "#publisher-poll-creator"

    Scenario: adding option to poll
      Given "#publisher-poll-creator" is hidden
      When I expand the publisher
      And I press the element "#poll_creator"
      And I press the element ".add-answer .button.creation"
      Then I should see 3 options

    Scenario: delete an option
      Given "#publisher-poll-creator" is hidden
      When I expand the publisher
      And I press the element "#poll_creator"
      And I press the element ".add-answer .button.creation"
      And I delete the last option
      Then I should see 2 option
      And I should not see a remove icon

    Scenario: post with an attached poll
      Given I expand the publisher
      And I press the element "#poll_creator"
      When I fill in the following:
          | status_message_fake_text    | I am eating yogurt |
          | poll_question               | What kind of yogurt do you like? |
      And I fill in the following for the options:
          | normal |
          | not normal  |
      And I press "Share"
      Then I should see a ".poll_form" within ".stream_element"
      And I should see a "form" within ".stream_element"

    Scenario: vote for an option
      Given I expand the publisher
      And I press the element "#poll_creator"
      When I fill in the following:
          | status_message_fake_text    | I am eating yogurt |
          | poll_question               | What kind of yogurt do you like? |
      And I fill in the following for the options:
          | normal |
          | not normal  |
      And I press "Share"

      And I check the first option
      And I press "Vote" within ".stream_element"
      Then I should see an element ".poll_progress_bar"
      And I should see an element ".percentage"
      And I should see "1 vote so far" within ".poll_statistic"

  Scenario: click to show result
    Given I expand the publisher
    And I press the element "#poll_creator"
    When I fill in the following:
        | status_message_fake_text    | I am eating yogurt |
        | poll_question               | What kind of yogurt do you like? |
    And I fill in the following for the options:
        | normal |
        | not normal  |
    And I press "Share"
    And I press the element ".toggle_result"
    Then I should see an element ".percentage"

  Scenario: validate answer input
    Given I expand the publisher
    And I press the element "#poll_creator"
    When I fill in the following:
        | status_message_fake_text    | I am eating yogurt |
        | poll_question               | What kind of yogurt do you like? |
    And I fill in the following for the options:
        | normal |
        |  |
    And I press the element "#publisher-poll-creator"
    And I press the element "input[type=submit]"
    Then I should see an element ".poll-answer.error"
