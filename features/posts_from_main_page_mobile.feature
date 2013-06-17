@javascript
Feature: posting from the mobile main page
    In order to navigate Diaspora*
    As a mobile user
    I want to tell the world I am eating a yogurt

    Background:
      Given following users exist:
        | username   |
        | bob        |
        | alice      |
      And I visit the mobile home page  
      And I sign in as "bob@bob.bob"
      And a user with username "bob" is connected with "alice"
      Given I have following aspects:
        | PostingTo            |
        | NotPostingThingsHere |
      And I have user with username "alice" in an aspect called "PostingTo"
      And I have user with username "alice" in an aspect called "NotPostingThingsHere"

    Scenario: posting some text
      Given I publisher mobile page
      And I append "I am eating yogurt" to the publisher mobile
      And I select "Unicorns" from "aspect_ids_"
      And I press "Share"
      When I visit the mobile stream page
      Then I should see "I am eating yogurt"

    Scenario: post a photo without text
      Given I publisher mobile page
      When I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload-publisher"
      And I wait for the ajax to finish
      Then I should see an uploaded image within the photo drop zone
      And I should see "button.png completed"
      When I press "Share"
      And I wait for the ajax to finish
      When I visit the mobile stream page
      Then I should see a "img" within ".stream_element div.photo_attachments"
      When I log out
      And I sign in as "alice@alice.alice"
      When I visit the mobile stream page
      Then I should see a "img" within ".stream_element div.photo_attachments"

    Scenario: back out of posting a photo-only post
      Given I publisher mobile page
      When I attach the file "spec/fixtures/bad_urls.txt" to "file" within "#file-upload-publisher"
      And I preemptively confirm the alert
      Then I should not see an uploaded image within the photo drop zone
      When I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload-publisher"
      And I wait for the ajax to finish
      And I should see "button.png completed"
      And I click to delete the first uploaded photo
      And I wait for the ajax to finish
      Then I should not see an uploaded image within the photo drop zone

    Scenario: back out of uploading a picture when another has been attached
      Given I publisher mobile page
      And I append "I am eating yogurt" to the publisher mobile
      And I attach the file "spec/fixtures/button.gif" to hidden element "file" within "#file-upload-publisher"
      And I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload-publisher"
      And I wait for the ajax to finish
      And I click to delete the first uploaded photo
      And I wait for the ajax to finish
      Then I should see an uploaded image within the photo drop zone
      And the text area wrapper mobile should be with attachments
