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
    And I should see "You should only report posts or comments which violates"
    When I fill in "report-reason-field" with "That's my reason"
    And I submit the form
    Then I should see a success flash message containing "The report has successfully been created"
    When I hover over the ".stream-element"
    And I click to report the post
    And I fill in "report-reason-field" with "That's my reason2"
    And I submit the form
    Then I should see an error flash message containing "The report already exists"
    When I go to the report page
    Then I should see a report by "alice" with reason "That's my reason" on post "I'm a post by Bob"

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
    Then I should see a report by "alice" with reason "That's my reason" on comment "Bob comment"
