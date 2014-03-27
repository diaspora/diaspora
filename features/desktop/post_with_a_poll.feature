@javascript
Feature: posting with a poll

    Background:
      Given following users exist:
        | username   |
        | bob        |
      And I sign in as "bob@bob.bob"
      And I am on the home page
      
    Scenario: expanding the publisher
      Given "#poll_creator_wrapper" is hidden
      When I expand the publisher
      Then I should see an element "#poll_creator"

    Scenario: expanding the poll creator
      Given "#poll_creator_wrapper" is hidden
      When I expand the publisher
      And I press the element "#poll_creator"
      Then I should see an element "#poll_creator_wrapper"

    Scenario: adding option to poll
      Given "#poll_creator_wrapper" is hidden
      When I expand the publisher
      And I press the element "#poll_creator"
      And I press the element "#add_poll_answer"
      Then I should see 3 options

    Scenario: delete an option
      Given "#poll_creator_wrapper" is hidden
      When I expand the publisher
      And I press the element "#poll_creator"
      And I delete the first option
      Then I should see 1 option
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