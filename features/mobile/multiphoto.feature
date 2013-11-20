@javascript
Feature: viewing photos on the mobile main page
  In order to navigate Diaspora*
  As a mobile user
  I want to view some photos

  Background:
    Given a user with username "bob"

    When I sign in as "bob@bob.bob"
    And I toggle the mobile view
    And I click on selector "img.compose_icon"

  Scenario: view full size image
    Given I attach the file "spec/fixtures/button.png" to hidden "file" within "#file-upload-publisher"

    When I press "Share"
    And I click on selector "img.stream-photo"
    Then I should see a "img" within "#show_content"
    And I should not see a "#right" within "#main"

  Scenario: view multiphoto post
    Given I attach the file "spec/fixtures/button.png" to hidden "file" within "#file-upload-publisher"
    And I attach the file "spec/fixtures/button.gif" to hidden "file" within "#file-upload-publisher"

    When I press "Share"
    Then I should see "+ 1" within ".additional_photo_count"

    When I click on selector "img.stream-photo"
    Then I should see a "#right" within "tbody"

    When I click on selector "img#arrow-right"
    And I should see a "#left" within "tbody"
    And I should not see a "#right" within "tbody"
