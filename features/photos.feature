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
    And I press "Share"
    And I wait for the ajax to finish

    When I go to the photo page for "bob@bob.bob"'s latest post
    And I follow "edit_photo_toggle"
    And I preemptively confirm the alert
    And I press "Delete Photo"
    And I go to the home page

    Then I should not see any posts in my stream

  Scenario: deleting a photo will not delete a photo-only post if another photo remains attached
    Given I expand the publisher
    And I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload"
    And I wait for the ajax to finish
    And I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload"
    And I wait for the ajax to finish
    And I press "Share"
    And I wait for the ajax to finish

    When I go to the photo page for "bob@bob.bob"'s latest post
    And I follow "edit_photo_toggle"
    And I preemptively confirm the alert
    And I press "Delete Photo"
    And I wait for the ajax to finish
    And I go to the home page

    Then I should see 1 posts

  Scenario: deleting a photo will not delete its parent post if the parent also contained text
    Given I expand the publisher
    And I fill in "status_message_fake_text" with "I am eating a yogurt"
    And I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload"
    And I wait for the ajax to finish
    And I press "Share"
    And I wait for the ajax to finish

    When I go to the photo page for "bob@bob.bob"'s latest post
    And I follow "edit_photo_toggle"
    And I preemptively confirm the alert
    And I press "Delete Photo"
    And I wait for the ajax to finish
    And I go to the home page

    Then I should see 1 posts
    And I should see "I am eating a yogurt" within ".stream_element"


