@javascript
Feature: viewing the photo lightbox
  Background:
    Given a user with username "alice"
    And "alice@alice.alice" has posted a status message with a photo
    And I sign in as "alice@alice.alice"

    Scenario: viewing a photo
      When I press the attached image
      Then I should see the photo lightbox

    Scenario: closing the lightbox by clicking the close link
      When I press the attached image
      And I press the close lightbox link
      Then I should not see the photo lightbox
