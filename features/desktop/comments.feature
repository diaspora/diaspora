@javascript
Feature: commenting
  In order to tell Alice how great the picture of her dog is
  As Alice's friend
  I want to comment on her post

  Background:
    Given following users exist:
      | username    | email             |
      | Bob Jones   | bob@bob.bob       |
      | Alice Smith | alice@alice.alice |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    When "alice@alice.alice" has posted a status message with a photo
    And I sign in as "bob@bob.bob"

  Scenario: comment on a post from within a user's stream
    When I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"
    When I focus the comment field
    And I fill in the following:
        | text            | is that a poodle?    |
    And I press "Comment"
    Then I should see "is that a poodle?" within ".comment"
    And I should see "less than a minute ago" within ".comment time"

  Scenario: delete a comment
    When "bob@bob.bob" has commented "is that a poodle?" on "Look at this dog"
    And I am on "alice@alice.alice"'s page
    Then I should see "is that a poodle?"
    When I confirm the alert after I click to delete the first comment
    Then I should not see "is that a poodle?"

  Scenario: expand the comment form in the main stream and an individual aspect stream
    Then I should see "Look at this dog"
    And the first comment field should be closed
    When I focus the comment field
    Then the first comment field should be open

    When I select only "Besties" aspect
    Then I should see "Look at this dog"
    And the first comment field should be closed
    When I focus the comment field
    Then the first comment field should be open

  Scenario: comment on a status show page
    When I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"
    When I follow "less than a minute ago"
    Then I should see "Look at this dog"
    When I make a show page comment "I think that’s a cat"
    Then I should see "less than a minute ago" within "#comments"
    When I go to "alice@alice.alice"'s page
    Then I should see "I think that’s a cat"

  Scenario: permalink to comment from within a users stream
    When "bob@bob.bob" has commented a lot on "Look at this dog"
    And "bob@bob.bob" has commented "I think that’s a cat" on "Look at this dog"
    And I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"
    And I should see "I think that’s a cat" within ".comment:last-child"
    When I follow "less than a minute ago" within ".comment:last-child"
    Then I should see "Look at this dog" within "#single-post-content"
    And I should see "I think that’s a cat" within ".comment .highlighted"
    And I should have scrolled down

  Scenario: permalink to comment from a status show page
    When "bob@bob.bob" has commented a lot on "Look at this dog"
    And "bob@bob.bob" has commented "I think that’s a cat" on "Look at this dog"
    And I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"
    When I follow "less than a minute ago" within "span.details.gray"
    Then I should see "I think that’s a cat" within ".comments .comment:last-child"
    When I follow "less than a minute ago" within ".comments .comment:last-child"
    Then I should see "I think that’s a cat" within ".comments .comment .highlighted"
    And I should have scrolled down

  Scenario: Show more comments after loading likes
    When "alice@alice.alice" has commented a lot on "Look at this dog"
    And "alice@alice.alice" has liked the post "Look at this dog"
    And I am on "alice@alice.alice"'s page
    Then I should see "Look at this dog"
    And I should not see "Comment 2"

    When I follow "1 Like"
    Then I should not see "1 Like"

    When I click on selector ".toggle_post_comments"
    Then I should see "Comment 2"

  Scenario: Like a comment in stream view
    When "alice@alice.alice" has commented "That's cool" on "Look at this dog"
    And I am on "alice@alice.alice"'s page
    And I like the comment "That's cool"
    Then I should see a like within comment "That's cool"

    When I expand likes within comment "That's cool"
    Then I should see a micro avatar within comment "That's cool"
    When I unlike comment "That's cool"
    Then I should not see a micro avatar within comment "That's cool"
