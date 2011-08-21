@javascript
Feature: dragging persons to an aspect

  Background:
    Given a user named "Bob Jones"
    And a user named "Alice Smith"
    When "alice@alice.alice" has posted a status message with a photo

  Scenario: dragging a person's image to an aspecct
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    When I drag the profile image in alice's post
    And I drop it onto the "Comment" aspect
    Then I should see "is that a poodle?" within "li.comment div.content"
