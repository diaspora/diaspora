@javascript
Feature: Creating a new post
  Background:
    Given a user with username "bob"
    And I sign in as "bob@bob.bob"
    And I trumpet

  Scenario: Posting a public message with a photo
    And I write "I love RMS"
    And I upload a fixture picture with filename "button.gif"
    When I start the framing process
    When I select "Public" in my aspects dropdown
    And I finalize my frame
    When I go to "/stream"
    Then I should see "I love RMS" as the first post in my stream
    And "I love RMS" should be a public post in my stream
    Then "I love RMS" should have the "button.gif" picture

  Scenario: Posting to Aspects
    And I write "This is super skrunkle"
    And I start the framing process
    When I select "All Aspects" in my aspects dropdown
    And I finalize my frame
    When I go to "/stream"
    Then I should see "This is super skrunkle" as the first post in my stream
    Then "This is super skrunkle" should be a limited post in my stream

  Scenario: Mention a contact
   Given a user named "Alice Smith" with email "alice@alice.alice"
   And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
   And I trumpet
   And I wait for the ajax to finish
   And I type "@a" to mention "Alice Smith"
   And I start the framing process
   Then the post should mention "Alice Smith"
   When I finalize my frame
   Then the post should mention "Alice Smith"

  Scenario: Uploading multiple photos
    When I write "check out these pictures"
    And I upload a fixture picture with filename "button.gif"
    And I upload a fixture picture with filename "button.gif"
    And I go through the default composer
    And I go to "/stream"
    Then "check out these pictures" should have 2 pictures

  Scenario: Framing your frame
    When I write "This is hella customized"
    And I upload a fixture picture with filename "button.gif"

    And I start the framing process
    #defaults to the prettiest mood
    Then the post's default mood should be "Wallpaper"
    Then it should be a wallpaper small frame with the background "button.gif"
    Then I should see "This is hella customized" in the framer preview

    When I select the mood "Newspaper"
    Then the post's mood should be "Newspaper"
    And "button.gif" should be in the post's small frame

    And I should see "This is hella customized" in the framer preview

    And I go back to the composer
    And I write "It sure is a beautiful Day"
    And I start the framing process
    Then the post's mood should be "Newspaper"
    And I should see "It sure is a beautiful Day" in the framer preview

    When I finalize my frame
    #on stream
    Then "It sure is a beautiful Day" should be the first canvas frame
    When I click into the "It sure is a beautiful Day" post

    #on show page
    And the post's mood should still be "Newspaper"

  Scenario: The Wallpaper mood
    When I write "This is a pithy status" with body "And this is a long body"
    And I upload a fixture picture with filename "button.gif"
    And I start the framing process
    When I select the mood "Wallpaper"
    Then it should be a wallpaper small frame with the background "button.gif"
    When I finalize my frame
    And I click into the "This is a pithy status" post
    And the frame's headline should be "This is a pithy status"
    And the frame's body should be "And this is a long body"
    Then it should be a wallpaper frame with the background "button.gif"

