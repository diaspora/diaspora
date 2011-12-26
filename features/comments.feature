@javascript
Feature: commenting
  In order to tell Alice how great the picture of her dog is
  As Alice's friend
  I want to comment on her post

  Background:
    Given a user named "Bob Jones" with email "bob@bob.bob"
    And a user named "Alice Smith" with email "alice@alice.alice"
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    When "alice@alice.alice" has posted a status message with a photo

  Scenario: comment on a post from within a user's stream
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"
    When I focus the comment field
    And I fill in "Comment" with "is that a poodle?"
    And I press "Comment"
    Then I should see "is that a poodle?" within "li.comment div.content"
    And I should see "less than a minute ago" within "li.comment time"

  Scenario: comment on a photo from the photo page
    When I sign in as "bob@bob.bob"
    And I am on the photo page for "alice@alice.alice"'s post "Look at this dog"
    And I wait for the ajax to finish
    And I focus the comment field
    And I fill in "Comment" with "hahahah"
    And I press "Comment"
    Then I should see "hahaha" within "li.comment div.content"
    And I should see "less than a minute ago" within "li.comment time"

  Scenario: comment on your own photo from the photo page
    When I sign in as "alice@alice.alice"
    And I am on the photo page for "alice@alice.alice"'s post "Look at this dog"
    And I wait for the ajax to finish
    And I focus the comment field
    And I fill in "Comment" with "hahahah"
    And I press "Comment"
    Then I should see "hahaha" within "li.comment div.content"
    And I should see "less than a minute ago" within "li.comment time"

  Scenario: delete a comment
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"
    When I focus the comment field
    And I fill in "Comment" with "is that a poodle?"
    And I press "Comment"
    And I wait for the ajax to finish
    When I hover over the ".comment"
    And I preemptively confirm the alert
    And I click to delete the first comment
    And I wait for the ajax to finish
    Then I should not see "is that a poodle?"

  Scenario: expand the comment form in the main stream and an individual aspect stream
    When I sign in as "bob@bob.bob"
    Then I should see "Look at this dog"
    Then the first comment field should be closed
    When I focus the comment field
    Then the first comment field should be open

    When I select only "Besties" aspect
    Then I should see "Look at this dog"
    Then the first comment field should be closed
    When I focus the comment field
    Then the first comment field should be open

  Scenario: comment on a status show page
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"
    When I follow "less than a minute ago"
    Then I should see "Look at this dog"
    When I focus the comment field
    And I fill in "text" with "I think thats a cat"
    And I press "Comment"
    And I wait for the ajax to finish
    When I am on "alice@alice.alice"'s page
    Then I should see "I think thats a cat"
