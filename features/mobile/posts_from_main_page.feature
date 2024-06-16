@javascript @mobile
Feature: posting from the mobile main page
  In order to navigate Diaspora*
  As a mobile user
  I want to tell the world I am eating a yogurt

  Background:
    Given following users exist:
      | username   |
      | bob        |
      | alice      |
    And I am on the home page
    And I sign in as "bob@bob.bob" on the mobile website
    And a user with username "bob" is connected with "alice"
    Given I have following aspects:
      | PostingTo            |
      | NotPostingThingsHere |
    And I have user with username "alice" in an aspect called "PostingTo"
    And I have user with username "alice" in an aspect called "NotPostingThingsHere"

  Scenario: post and delete some text
    Given I visit the mobile publisher page
    And I append "I am eating yogurt" to the publisher
    And I press the aspect dropdown
    And I toggle the aspect "Unicorns"
    And I press the share button
    When I go to the stream page
    Then I should see "I am eating yogurt"
    When I confirm the alert after I click on selector "a.remove"
    Then I should not see "I am eating yogurt"

  Scenario: post in multiple aspects
    Given I visit the mobile publisher page
    And I append "I am selecting my friends" to the publisher
    And I press the aspect dropdown
    And I toggle the aspect "PostingTo"
    And I toggle the aspect "Unicorns"
    And I press the share button

    When I visit the stream with aspect "PostingTo"
    Then I should see "I am selecting my friends"
    
    When I visit the stream with aspect "Unicorns"
    Then I should see "I am selecting my friends"

    When I visit the stream with aspect "NotPostingThingsHere"
    Then I should not see "I am selecting my friends"

  Scenario: post a photo without text
    Given I visit the mobile publisher page
    When I attach the file "spec/fixtures/button.png" to hidden "qqfile" within "#file-upload-publisher"
    Then I should see "button.png completed"
    And I should see an uploaded image within the photo drop zone
    When I press "Share"
    When I go to the stream page
    Then I should see a "img" within ".stream-element div.photo-attachments"
    When I log out
    And I sign in as "alice@alice.alice" on the mobile website
    When I go to the stream page
    Then I should see a "img" within ".stream-element div.photo-attachments"

  Scenario: back out of posting a photo-only post
    Given I visit the mobile publisher page
    When I accept the alert after I attach the file "spec/fixtures/bad_urls.txt" to "qqfile" within "#file-upload-publisher"
    Then I should not see an uploaded image within the photo drop zone
    When I attach the file "spec/fixtures/button.png" to hidden "qqfile" within "#file-upload-publisher"
    And I should see "button.png completed"
    And I click to delete the first uploaded photo
    Then I should not see an uploaded image within the photo drop zone

  Scenario: back out of uploading a picture when another has been attached
    Given I visit the mobile publisher page
    And I append "I am eating yogurt" to the publisher
    And I attach the file "spec/fixtures/button.gif" to hidden "qqfile" within "#file-upload-publisher"
    And I attach the file "spec/fixtures/button.png" to hidden "qqfile" within "#file-upload-publisher"
    And I click to delete the first uploaded photo
    Then I should see an uploaded image within the photo drop zone
    And the text area wrapper mobile should be with attachments
