@javascript @mobile
Feature: viewing photos on the mobile main page
  In order to navigate Diaspora*
  As a mobile user
  I want to view some photos

  Background:
    Given a user with username "bob"
    And I sign in as "bob@bob.bob" on the mobile website

  Scenario: view full size image
    Given I visit the mobile publisher page
    When I attach the file "spec/fixtures/button.png" to hidden "qqfile" within "#file-upload-publisher"
    Then I should see "button.png completed"
    And I should see an uploaded image within the photo drop zone

    When I press "Share"
    And I go to the stream page
    And I click on selector "img.stream-photo"
    Then I should see a "img" within ".photos"
    And I should not see a "#arrow-right" within "#main"
    And I should not see a "#arrow-left" within "#main"

  Scenario: view multiphoto post
    Given I visit the mobile publisher page
    When I attach the file "spec/fixtures/button.png" to hidden "qqfile" within "#file-upload-publisher"
    Then I should see "button.png completed"
    When I attach the file "spec/fixtures/button.gif" to hidden "qqfile" within "#file-upload-publisher"
    Then I should see "button.gif completed"

    When I press "Share"
    And I go to the stream page
    Then I should see "+ 1" within ".additional_photo_count"

    When I click on selector "img.stream-photo"
    Then I should see a "#arrow-right" within "#main"
    And I should not see a "#arrow-left" within "#main"

    When I click on selector "#arrow-right"
    Then I should see a "#arrow-left" within "#main"
    And I should not see a "#arrow-right" within "#main"
