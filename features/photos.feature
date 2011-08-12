@javascript
Feature: photos
    In order to enlighten humanity for the good of society
    As a rock star
    I want to post pictures of a button

  Background:
      Given a user with username "bob"
      When I sign in as "bob@bob.bob"

      And I am on the home page

  Scenario: deleting a photo will delete a photo-only post if the photo was the last image
    Given I expand the publisher
    And I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload"
    And I wait for the ajax to finish
    Then I should see an uploaded image within the photo drop zone
    And I press "Share"
    And I wait for the ajax to finish
    And I follow "Your Aspects"
    Then I should see a "img" within ".stream_element div.photo_attachments"

