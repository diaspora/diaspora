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
      And I sign in as "bob@bob.bob"
      And a user with username "bob" is connected with "alice"
      Given I have following aspects:
        | PostingTo            |
        | NotPostingThingsHere |
      And I have user with username "alice" in an aspect called "PostingTo"
      And I have user with username "alice" in an aspect called "NotPostingThingsHere"
      And I am on the home page

    Scenario: expanding the publisher
      Given ".markdownIndications" is hidden
      And ".options_and_submit" is hidden
      When I expand the publisher
      Then I should see "You can use Markdown to format your post" within "#publisher-images"
      Then I should see "All Aspects" within ".options_and_submit"
      Then I should see "Preview" within ".options_and_submit"

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

      And I go to the aspects page
      Then "The World needs more Cats." should be post 1
      Then "The World needs more Cats." should be post 2

    Scenario: posting a message appends it to the top of the stream
      When I click the publisher and post "sup dog"
      And I click the publisher and post "hello there"
      Then I should see "hello there" as the first post in my stream

    Scenario: post a text-only message to just one aspect
      When I select only "PostingTo" aspect
      And I expand the publisher
      When I write the status message "I am eating a yogurt"

      And I submit the publisher

      When I am on the aspects page
      And I select only "PostingTo" aspect
      Then I should see "I am eating a yogurt"

      When I am on the aspects page
      And I select only "NotPostingThingsHere" aspect
      Then I should not see "I am eating a yogurt"

    Scenario: post a photo with text
      Given I expand the publisher
      And I attach "spec/fixtures/button.png" to the publisher
      When I write the status message "Look at this dog"
      And I submit the publisher
      And I go to the aspects page
      Then I should see a "img" within ".stream_element div.photo_attachments"
      And I should see "Look at this dog" within ".stream_element"
      When I log out
      And I sign in as "alice@alice.alice"
      And I go to "bob@bob.bob"'s page
      Then I should see a "img" within ".stream_element div.photo_attachments"
      And I should see "Look at this dog" within ".stream_element"

    Scenario: post a photo without text
      Given I expand the publisher
      And I attach "spec/fixtures/button.png" to the publisher
      Then I should see an uploaded image within the photo drop zone
      When I press "Share"
      And I go to the aspects page
      Then I should see a "img" within ".stream_element div.photo_attachments"
      When I log out
      And I sign in as "alice@alice.alice"
      And I go to "bob@bob.bob"'s page
      Then I should see a "img" within ".stream_element div.photo_attachments"

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

    Scenario: back out of uploading a picture when another has been attached
      Given I expand the publisher
      And I have turned off jQuery effects
      When I write the status message "I am eating a yogurt"
      And I attach "spec/fixtures/button.png" to the publisher
      And I attach "spec/fixtures/button.png" to the publisher
      And I click to delete the first uploaded photo
      Then I should see an uploaded image within the photo drop zone
      And the publisher should be expanded

    @wip
    Scenario: hide a contact's post
      Given I expand the publisher
      When I write the status message "Here is a post for you to hide"
      And I submit the publisher

      And I log out
      And I sign in as "alice@alice.alice"
      And I am on "bob@bob.bob"'s page

      And I hover over the ".stream_element"
      And I click to delete the first post
      And I confirm the alert
      And I go to "bob@bob.bob"'s page
      Then I should not see "Here is a post for you to hide"
      When I am on the aspects page
      Then I should not see "Here is a post for you to hide"

    Scenario: delete one of my posts
      Given I expand the publisher
      When I write the status message "I am eating a yogurt"
      And I submit the publisher
      And I go to the aspects page
      And I hover over the ".stream_element"
      And I click to delete the first post
      And I go to the aspects page
      Then I should not see "I am eating a yogurt"

    Scenario: change post target aspects with the aspect-dropdown before posting
      When I expand the publisher
      And I press the aspect dropdown
      And I toggle the aspect "PostingTo"
      And I append "I am eating a yogurt" to the publisher
      And I submit the publisher

      And I am on the aspects page
      And I select only "PostingTo" aspect
      Then I should see "I am eating a yogurt"
      When I am on the aspects page
      And I select only "NotPostingThingsHere" aspect
      Then I should not see "I am eating a yogurt"

    Scenario: post 2 in a row using the aspects-dropdown
      When I expand the publisher
      And I press the aspect dropdown
      And I toggle the aspect "PostingTo"
      And I append "I am eating a yogurt" to the publisher
      And I submit the publisher

      And I expand the publisher
      And I press the aspect dropdown
      And I toggle the aspect "Besties"
      And I append "And cornflakes also" to the publisher
      And I submit the publisher

      And I am on the aspects page
      And I select only "PostingTo" aspect
      Then I should see "I am eating a yogurt" and "And cornflakes also"
      When I am on the aspects page
      And I select only "Besties" aspect
      Then I should not see "I am eating a yogurt"
      Then I should see "And cornflakes also"
      When I am on the aspects page
      And I select only "NotPostingThingsHere" aspect
      Then I should not see "I am eating a yogurt" and "And cornflakes also"

    # (NOTE) make this a jasmine spec
    Scenario: reject deletion one of my posts
      When I expand the publisher
      When I write the status message "I am eating a yogurt"
      And I submit the publisher

      And I hover over the ".stream_element"
      And I prepare the deletion of the first post
      And I reject the alert
      Then I should see "I am eating a yogurt"
