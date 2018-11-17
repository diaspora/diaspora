@javascript
Feature: posting with a poll

    Background:
      Given following users exist:
        | username   |
        | bob        |
      And I sign in as "bob@bob.bob"

    Scenario: expanding the publisher
      Given "#poll_creator_container" is hidden
      When I expand the publisher
      Then I should see an element "#poll_creator"

    Scenario: expanding the poll creator
      Given "#poll_creator_container" is hidden
      When I expand the publisher
      And I click on selector "#poll_creator"
      Then I should see an element "#poll_creator_container"

    Scenario: adding option to poll
      Given "#poll_creator_container" is hidden
      When I expand the publisher
      And I click on selector "#poll_creator"
      And I fill in values for the first two options
      And I lose focus
      Then I should see 3 options

    Scenario: delete an option
      Given "#poll_creator_container" is hidden
      When I expand the publisher
      And I click on selector "#poll_creator"
      And I fill in values for the first two options
      And I lose focus
      And I delete the last option
      Then I should see 2 options
      And I should not see a remove icon

    Scenario: post with an attached poll
      Given I expand the publisher
      And I click on selector "#poll_creator"
      When I fill in the following:
          | status_message_text    | I am eating yogurt |
          | poll_question          | What kind of yogurt do you like? |
      And I fill in the following for the options:
          | normal |
          | not normal  |
      And I press "Share"
      Then I should see a ".poll-form" within ".stream-element"
      And I should see a "form" within ".stream-element"

    Scenario: vote for an option
      Given I expand the publisher
      And I click on selector "#poll_creator"
      When I fill in the following:
          | status_message_text    | I am eating yogurt |
          | poll_question          | What kind of yogurt do you like? |
      And I fill in the following for the options:
          | normal |
          | not normal  |
      And I press "Share"

      And I check the first option
      And I press "Vote" within ".stream-element"
      Then I should see an element ".progress-bar"
      And I should see an element ".percentage"
      And I should see "1 vote so far" within ".poll-statistic"

  Scenario: click to show result
    Given I expand the publisher
    And I click on selector "#poll_creator"
    When I fill in the following:
        | status_message_text    | I am eating yogurt |
        | poll_question          | What kind of yogurt do you like? |
    And I fill in the following for the options:
        | normal |
        | not normal  |
    And I press "Share"
    And I click on selector ".toggle-result"
    Then I should see an element ".percentage"

  Scenario: validate answer input
    Given I expand the publisher
    And I click on selector "#poll_creator"
    When I fill in the following:
        | status_message_text    | I am eating yogurt |
        | poll_question          | What kind of yogurt do you like? |
    And I fill in the following for the options:
        | normal |
        |  |
    And I click on selector "#poll_creator_container"
    And I click on selector "#publisher button#submit"
    Then I should see an element ".poll-answer input.error"
