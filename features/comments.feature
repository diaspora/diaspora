@javascript
Feature: commenting
  In order to tell alice how great the picture of her dog is
  As alice's friend
  I want to comment on her post

  Background:
    Given a user named "Bob Jones" with email "bob@bob.bob"
    And a user named "Alice Smith" with email "alice@alice.alice"
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
   When I sign in as "alice@alice.alice"
    And I am on the home page
    And I expand the publisher
    And I fill in "status_message_fake_text" with "Look at this dog"
    And I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload"
    And I press "Share"
    And I follow "Home"
   Then I should see "Look at this dog" within ".stream_element"
   Then I should see a "img" within ".stream_element div.photo_attachments"
    And I log out

  Scenario: comment on a post from within a user's stream
    When  I sign in as "bob@bob.bob"
    And   I am on "alice@alice.alice"'s page
    Then  I should see "Look at this dog"
    When  I focus the comment field
    And   I fill in "Comment" with "is that a poodle?"
    And   I press "Comment"
    Then  I should see "is that a poodle?" within "li.comment div.content"
    And   I should see "less than a minute ago" within "li.comment time"

  Scenario: comment on a photo from the photo page
    When  I sign in as "bob@bob.bob"
     And  I am on the photo page for "alice@alice.alice"'s post "Look at this dog"
     And  I focus the comment field
     And  I fill in "Comment" with "hahahah"
     And  I press "Comment"
    Then  I should see "hahaha" within "li.comment div.content"
    And   I should see "less than a minute ago" within "li.comment time"

  Scenario: comment on your own photo from the photo page
    When  I sign in as "alice@alice.alice"
     And  I am on the photo page for "alice@alice.alice"'s post "Look at this dog"
     And  I focus the comment field
     And  I fill in "Comment" with "hahahah"
     And  I press "Comment"
    Then  I should see "hahaha" within "li.comment div.content"
    And   I should see "less than a minute ago" within "li.comment time"
