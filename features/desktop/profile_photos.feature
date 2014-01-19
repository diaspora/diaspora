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

    Scenario: see my own photos
      When I am on "robert@grimm.grimm"'s page
      And I follow "View all" within ".image_list"
      Then I should be on person_photos page

    Scenario: I cannot see photos of people who don't share with me
      When I sign in as "alice@alice.alice"
      And I am on "robert@grimm.grimm"'s page
      Then I should not see "photos" within "div#profile"
