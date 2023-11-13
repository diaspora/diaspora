@javascript
Feature: reporting of posts and comments

  Background:
    Given a user with username "bob"
    And a moderator with email "alice@alice.alice"
    And "bob@bob.bob" has a public post with text "I'm a post by Bob"
    And the terms of use are enabled

  Scenario: User can report a post, but cannot report it twice
    Given I sign in as "alice@alice.alice"
    And I am on the public stream page
    When I hover over the ".stream-element"
    And I click to report the post
    Then I should see the report modal
    And I should see "Please only report content that violates"
    When I fill in "report-reason-field" with "That's my reason"
    And I submit the form
    Then I should see a success flash message containing "The report has successfully been created"
    When I hover over the ".stream-element"
    And I click to report the post
    And I fill in "report-reason-field" with "That's my reason2"
    And I submit the form
    Then I should see an error flash message containing "The report already exists"
    When I go to the report page
    Then I should see a report by "alice@alice.alice" with reason "That's my reason" on post "I'm a post by Bob"
    And "alice@alice.alice" should have received an email with subject "A new post was marked as offensive"

  Scenario: User can report a comment, but cannot report it twice
    Given "bob@bob.bob" has commented "Bob comment" on "I'm a post by Bob"
    And I sign in as "alice@alice.alice"
    And I am on the public stream page
    When I hover over the ".comment"
    And I click to report the comment
    Then I should see the report modal
    When I fill in "report-reason-field" with "That's my reason"
    And I submit the form
    Then I should see a success flash message containing "The report has successfully been created"
    When I hover over the ".comment"
    And I click to report the comment
    And I fill in "report-reason-field" with "That's my reason2"
    And I submit the form
    Then I should see an error flash message containing "The report already exists"
    When I go to the report page
    Then I should see a report by "alice@alice.alice" with reason "That's my reason" on comment "Bob comment"
    And "alice@alice.alice" should have received an email with subject "A new comment was marked as offensive"

  Scenario: The correct post is reported
    Given "bob@bob.bob" has a public post with text "I'm a second post by Bob"
    And I sign in as "alice@alice.alice"
    And I am on the public stream page
    When I hover over the ".stream-element:nth-child(2)"
    And I click to report the post
    And I fill in "report-reason-field" with "post 1"
    And I close the modal
    And I hover over the ".stream-element:first-child"
    And I click to report the post
    Then the "report-reason" field should be filled with ""
    When I fill in "report-reason-field" with "post 2"
    And I submit the form
    And I go to the report page
    Then I should see "I'm a second post by Bob" within ".content"
    And I should see "post 2" within ".reason"
    And I should see "alice" within ".reporter"
