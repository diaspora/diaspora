@javascript
Feature: Issue #3382 The comments under postings are missing when using the #tags -view

  Background:
    Given a user named "Bob Jones" with email "bob@bob.bob"
    And I sign in as "bob@bob.bob"
    When I post a status with the text "This is a post with a #tag"
    And I am on the homepage

  Scenario:
    When I search for "#tag"
    Then I should be on the tag page for "tag"
    And I should see "This is a post with a #tag"

  Scenario:
    When I comment "this is a comment on my post" on "This is a post with a #tag"
    And I search for "#tag"
    Then I should be on the tag page for "tag"
    And I should see "this is a comment on my post"


