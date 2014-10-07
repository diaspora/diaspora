@javascript
Feature: show photos

  Background:
    Given following users exist:
      | username      | email               |
      | Bob Jones     | bob@bob.bob         |
      | Alice Smith   | alice@alice.alice   |
      | Robert Grimm  | robert@grimm.grimm  |
    And I sign in as "robert@grimm.grimm"

    Given I expand the publisher
    And I have turned off jQuery effects
    And I attach the file "spec/fixtures/button.png" to hidden "file" within "#file-upload"
    And I press "Share"
    Then I should see a "img" within ".stream_element div.photo_attachments"

    Scenario: see my own photos
      When I am on "robert@grimm.grimm"'s page
      #TODO: find out why images don't show on first load
      And I am on "robert@grimm.grimm"'s page
      And I press the first "#photos_link"
      Then I should be on person_photos page

    Scenario: I cannot see photos of people who don't share with me
      When I sign in as "alice@alice.alice"
      And I am on "robert@grimm.grimm"'s page
      Then I should not see "Photos" within "#profile_horizontal_bar"

    Scenario: I delete a photo
      When I am on "robert@grimm.grimm"'s photos page
      And I delete a photo
      And I confirm the alert
      And I am on "robert@grimm.grimm"'s page
      Then I should not see "Photos" within "#profile_horizontal_bar"
