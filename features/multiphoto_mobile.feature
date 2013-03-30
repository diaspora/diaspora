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
    Given I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload-publisher"
    And I wait for the ajax to finish
    When I press "Share"
    And I wait for the ajax to finish
    And I click on selector "img.stream-photo"
    Then I should see a "img" within "#show_content"
    And I should not see a "#right" within ".row"

  Scenario: view multiphoto post
    Given I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload-publisher"
    And I wait for the ajax to finish
    And I attach the file "spec/fixtures/button.gif" to hidden element "file" within "#file-upload-publisher"
    And I wait for the ajax to finish
    When I press "Share"
    And I wait for the ajax to finish
    And I should see "+ 1" within ".additional_photo_count"
    And I click on selector "img.stream-photo"
    Then I should see a "#right" within "tbody"
    And I click on selector "img#arrow-right"
    And I should see a "#left" within "tbody"
    And I should not see a "#right" within "tbody"
