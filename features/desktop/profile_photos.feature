@javascript
Feature: show photos

  Background:
    Given following users exist:
      | username      | email               |
      | Bob Jones     | bob@bob.bob         |
      | Alice Smith   | alice@alice.alice   |
      | Robert Grimm  | robert@grimm.grimm  |
    And "robert@grimm.grimm" has posted a status message with a photo
    And I sign in as "robert@grimm.grimm"

    Scenario: see my own photos
      When I am on "robert@grimm.grimm"'s page
      And I press the first "#photos_link"
      Then I should be on person_photos page

    Scenario: I cannot see photos of people who don't share with me
      When I sign in as "alice@alice.alice"
      And I am on "robert@grimm.grimm"'s page
      Then I should not see "Photos" within "#profile-horizontal-bar"

    Scenario: I can see public photos of people who share with me
      When "robert@grimm.grimm" has posted a public status message with a photo
      And I sign in as "alice@alice.alice"
      And I am on "robert@grimm.grimm"'s page
      Then I should see "Photos" within "#profile-horizontal-bar"
      When I press the first "#photos_link"
      Then I should be on "robert@grimm.grimm"'s photos page
      And I should see "Photos" within "#profile-horizontal-bar"

    Scenario: I delete a photo
      When I am on "robert@grimm.grimm"'s photos page
      Then I should see a ".thumbnail" within "#main-stream"
      When I confirm the alert after I delete a photo
      Then I should not see a ".thumbnail" within "#main-stream"
      When I am on "robert@grimm.grimm"'s page
      Then I should not see "Photos" within "#profile-horizontal-bar"
