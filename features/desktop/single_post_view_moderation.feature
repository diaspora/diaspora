@javascript
  Feature: using SPV moderation buttons

  Background:
    Given following users exist:
      | username   |
      | bob        |
      | alice      |
    And a user with username "bob" is connected with "alice"
    And "bob@bob.bob" has a public post with text "Here is a post to test with"

  Scenario: hide a contact's post
    When I sign in as "alice@alice.alice"
    And I open the show page of the "Here is a post to test with" post
    And I confirm the alert after I click to hide the post
    Then I should be on the stream page

  Scenario: block a contact
    When I sign in as "alice@alice.alice"
    And I open the show page of the "Here is a post to test with" post
    And I confirm the alert after I click to block the user
    Then I should be on the stream page

  Scenario: report a contact
    When I sign in as "alice@alice.alice"
    And I open the show page of the "Here is a post to test with" post
    And I click to report the post
    When I fill in "report-reason-field" with "That's my reason"
    And I submit the form
    And I should see a flash message containing "The report has successfully been created"

  Scenario: delete own post
    When I sign in as "bob@bob.bob"
    And I open the show page of the "Here is a post to test with" post
    And I confirm the alert after I click to delete the post
    Then I should be on the stream page
