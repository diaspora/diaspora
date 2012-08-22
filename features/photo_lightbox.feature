@javascript
Feature: viewing the photo lightbox
  Background:
    Given I am on the home page
    And a user with username "bob"

    When I sign in as "bob@bob.bob"
    And I am on the home page

    Given I expand the publisher
    And I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload"
    And I fill in the following:
        | status_message_fake_text    | Look at this dog    |
    And I press "Share"
    And I wait for the ajax to finish

    Scenario: viewing a photo
      Then I should see an image attached to the post
      And I press the attached image
      Then I should see the photo lightbox

    Scenario: closing the lightbox by clicking the close link
      Then I should see an image attached to the post
      And I press the attached image
      And I press the close lightbox link
      Then I should not see the photo lightbox

    Scenario: closing the lightbox by clicking the backdrop
      Then I should see an image attached to the post
      And I press the attached image
      And I press the lightbox backdrop
      Then I should not see the photo lightbox
