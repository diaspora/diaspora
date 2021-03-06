@javascript
Feature: posting from the main page
    In order to enlighten humanity for the good of society
    As a rock star
    I want to tell the world I am eating a yogurt

    Background:
      Given following users exist:
        | username   |
        | bob        |
        | alice      |
      And a user with username "bob" is connected with "alice"
      And I sign in as "bob@bob.bob"
      And I have following aspects:
        | PostingTo            |
        | NotPostingThingsHere |
      And I have user with username "alice" in an aspect called "PostingTo"
      And I have user with username "alice" in an aspect called "NotPostingThingsHere"
      And I go to the home page

    Scenario: expanding the publisher
      Given ".markdownIndications" is hidden
      And ".options_and_submit" is hidden
      When I expand the publisher
      Then I should see "You can use Markdown to format your post" within ".markdownIndications"
      Then I should see "All aspects" within ".options_and_submit"
      Then I should see a ".md-write-tab" within ".md-header"
      Then I should see a ".md-preview-tab" within ".md-header"

    Scenario: post a text-only message to all aspects
      Given I expand the publisher
      When I write the status message "I am eating yogurt"
      And I submit the publisher

      And I go to the aspects page
      Then "I am eating yogurt" should be post 1

    Scenario: re-posting a text-only message
      Given I expand the publisher
      When I write the status message "The World needs more Cats."
      And I submit the publisher

      Given I expand the publisher
      When I write the status message "The World needs more Cats."
      And I submit the publisher
      Then "The World needs more Cats." should be post 1
      And "The World needs more Cats." should be post 2

      When I go to the aspects page
      Then "The World needs more Cats." should be post 1
      And "The World needs more Cats." should be post 2

    Scenario: posting a message appends it to the top of the stream
      When I click the publisher and post "sup dog"
      And I click the publisher and post "hello there"
      Then "hello there" should be post 1

    Scenario: post a text-only message to just one aspect
      When I select only "PostingTo" aspect
      And I expand the publisher
      When I write the status message "I am eating a yogurt"

      And I submit the publisher

      When I am on the aspects page
      And I select all aspects
      And I select only "PostingTo" aspect
      Then "I am eating a yogurt" should be post 1

      When I am on the aspects page
      And I select all aspects
      And I select only "NotPostingThingsHere" aspect
      Then I should not see "I am eating a yogurt"

    Scenario: post a photo with text
      Given I expand the publisher
      And I attach "spec/fixtures/button.png" to the publisher
      When I write the status message "Look at this dog"
      And I submit the publisher
      And I go to the aspects page
      Then I should see a "img" within ".stream-element div.photo-attachments"
      And I should see "Look at this dog" within ".stream-element"
      When I log out
      And I sign in as "alice@alice.alice"
      And I go to "bob@bob.bob"'s page
      Then I should see a "img" within ".stream-element div.photo-attachments"
      And I should see "Look at this dog" within ".stream-element"

    Scenario: post a photo without text
      Given I expand the publisher
      And I attach "spec/fixtures/button.png" to the publisher
      Then I should see an uploaded image within the photo drop zone
      When I press "Share"
      Then I should see a "img" within ".stream-element div.photo-attachments"
      When I go to the aspects page
      Then I should see a "img" within ".stream-element div.photo-attachments"
      When I log out
      And I sign in as "alice@alice.alice"
      And I go to "bob@bob.bob"'s page
      Then I should see a "img" within ".stream-element div.photo-attachments"

    Scenario: back out of posting a photo-only post
      Given I expand the publisher
      And I attach "spec/fixtures/button.png" to the publisher
      When I click to delete the first uploaded photo
      Then I should not see an uploaded image within the photo drop zone
      And I should not be able to submit the publisher

    Scenario: back out of uploading a picture to a post with text
      Given I expand the publisher
      And I have turned off jQuery effects
      When I write the status message "I am eating a yogurt"
      And I attach "spec/fixtures/button.png" to the publisher
      And I click to delete the first uploaded photo
      Then I should not see an uploaded image within the photo drop zone
      And the publisher should be expanded
      And I close the publisher

    Scenario: back out of uploading a picture when another has been attached
      Given I expand the publisher
      And I have turned off jQuery effects
      When I write the status message "I am eating a yogurt"
      And I attach "spec/fixtures/button.png" to the publisher
      And I attach "spec/fixtures/button.png" to the publisher
      And I click to delete the first uploaded photo
      Then I should see an uploaded image within the photo drop zone
      And the publisher should be expanded
      And I close the publisher

    Scenario: hide a contact's post
      Given I expand the publisher
      When I write the status message "Here is a post for you to hide"
      And I submit the publisher

      And I log out
      And I sign in as "alice@alice.alice"
      And I am on "bob@bob.bob"'s page

      And I hover over the ".stream-element"
      And I click to hide the first post
      And I go to "bob@bob.bob"'s page
      Then I should not see "Here is a post for you to hide"
      When I am on the aspects page
      Then I should not see "Here is a post for you to hide"

    Scenario: delete one of my posts
      Given I expand the publisher
      When I write the status message "I am eating a yogurt"
      And I submit the publisher
      And I go to the aspects page
      And I hover over the ".stream-element"
      And I click to delete the first post
      And I go to the aspects page
      Then I should not see "I am eating a yogurt"

    Scenario: change post target aspects with the aspect-dropdown before posting
      When I expand the publisher
      And I press the aspect dropdown
      And I toggle the aspect "PostingTo"
      And I press the aspect dropdown
      And I append "I am eating a yogurt" to the publisher
      And I submit the publisher

      And I am on the aspects page
      And I select only "PostingTo" aspect
      Then "I am eating a yogurt" should be post 1
      When I am on the aspects page
      And I select all aspects
      And I select only "NotPostingThingsHere" aspect
      Then I should not see "I am eating a yogurt"

    Scenario: post 2 in a row using the aspects-dropdown
      When I expand the publisher
      And I press the aspect dropdown
      And I toggle the aspect "PostingTo"
      And I press the aspect dropdown
      And I append "I am eating a yogurt" to the publisher
      And I submit the publisher

      And I expand the publisher
      And I press the aspect dropdown
      And I toggle the aspect "Besties"
      And I press the aspect dropdown
      And I append "And cornflakes also" to the publisher
      And I submit the publisher

      And I am on the aspects page
      And I select only "PostingTo" aspect
      Then I should see "I am eating a yogurt" and "And cornflakes also"
      When I am on the aspects page
      And I select all aspects
      And I select only "Besties" aspect
      Then I should not see "I am eating a yogurt"
      Then I should see "And cornflakes also"
      When I am on the aspects page
      And I select all aspects
      And I select only "NotPostingThingsHere" aspect
      Then I should not see "I am eating a yogurt" and "And cornflakes also"

    Scenario: Write html in the publisher
      When I expand the publisher
      Then I should not see any alert after I write the status message "<script>alert();</script>"
      When I submit the publisher
      Then "<script>alert();</script>" should be post 1

    # (NOTE) make this a jasmine spec
    Scenario: reject deletion one of my posts
      When I expand the publisher
      When I write the status message "I am eating a yogurt"
      And I submit the publisher

      And I hover over the ".stream-element"
      And I reject the alert after I prepare the deletion of the first post
      Then I should see "I am eating a yogurt"
