@javascript @mobile
Feature: viewing photos on the mobile main page
  In order to navigate Diaspora*
  As a mobile user
  I want to view some photos

  Background:
    Given a user with username "bob"
    When I sign in as "bob@bob.bob" on the mobile website
    And I click on selector "#compose-badge"

  Scenario: view full size image
    Given I attach the file "spec/fixtures/button.png" to hidden "file" within "#file-upload-publisher"

    When I press "Share"
    And I click on selector "img.stream-photo"
    Then I should see a "img" within "#show_content"
    And I should not see a "#arrow-right" within "#main"
    And I should not see a "#arrow-left" within "#main"

  Scenario: view multiphoto post
    Given I attach the file "spec/fixtures/button.png" to hidden "file" within "#file-upload-publisher"
    And I attach the file "spec/fixtures/button.gif" to hidden "file" within "#file-upload-publisher"

    When I press "Share"
    Then I should see "+ 1" within ".additional_photo_count"

    When I click on selector "img.stream-photo"
    Then I should see a "#arrow-right" within "#main"
    And I should not see a "#arrow-left" within "#main"

    When I click on selector "#arrow-right"
    Then I should see a "#arrow-left" within "#main"
    And I should not see a "#arrow-right" within "#main"
