@javascript @mobile
Feature: Navigate between pages using the header menu and the drawer
  As a user
  I want to be able navigate between the pages of the mobile version

  Background:
    Given a user with email "alice@alice.alice"
    And I sign in as "alice@alice.alice" on the mobile website

  Scenario: navigate to the stream page
    When I go to the activity stream page
    And I click on selector ".header-title"
    Then I should be on the stream page

  Scenario: navigate to the notification page
    When I click on selector "#notification-badge"
    Then I should be on the notifications page

  Scenario: navigate to the conversation page
    When I click on selector "#conversations-badge"
    Then I should be on the conversations page

  Scenario: navigate to the publisher page
    When I click on selector "#compose-badge"
    Then I should be on the new status message page

  Scenario: search a user
    When I open the drawer
    Then I should see a "#q" within "#drawer"
    When I search for "Bob"
    Then I should see "Users matching Bob" within "#search_title"

  Scenario: search for a tag
    When I open the drawer
    Then I should see a "#q" within "#drawer"
    When I search for "#bob"
    Then I should be on the tag page for "bob"

  Scenario: navigate to the stream page
    When I open the drawer
    And I click on "Stream" in the drawer
    Then I should be on the stream page

  Scenario: navigate to my activity page
    When I open the drawer
    And I click on "My activity" in the drawer
    Then I should be on the activity stream page

  Scenario: navigate to my mentions page
    When I open the drawer
    And I click on "@Mentions" in the drawer
    Then I should be on the mentioned stream page

  Scenario: navigate to aspects pages
    Given I have a limited post with text "Hi you!" in the aspect "Besties"
    When I open the drawer
    Then I should not see "All aspects" within "#drawer"
    And I click on "My aspects" in the drawer
    And I click on "All aspects" in the drawer
    Then I should be on the aspects page
    And I should see "Hi you!" within "#main-stream"
    When I open the drawer
    And I click on "My aspects" in the drawer
    And I click on "Unicorns" in the drawer
    And I should not see "Hi you!" within "#main-stream"

  Scenario: navigate to the followed tags page
    When I follow the "boss" tag
    And I go to the stream page
    And I open the drawer
    Then I should not see "All tags" within "#drawer"
    And I click on "#Followed tags" in the drawer
    And I click on "All tags" in the drawer
    Then I should be on the followed tags stream page

  Scenario: navigate to the boss tag page
    When I follow the "boss" tag
    And I go to the stream page
    And I open the drawer
    And I click on "#Followed tags" in the drawer
    And I click on "#boss" in the drawer
    Then I should be on the tag page for "boss"

    When I open the drawer
    And I click on "#Followed tags" in the drawer
    And I click on "Manage followed tags" in the drawer
    Then I should be on the manage tag followings page

  Scenario: navigate to the public stream page
    When I open the drawer
    And I click on "Public activity" in the drawer
    Then I should be on the public stream page

  Scenario: navigate to my profile page
    When I open the drawer
    And I click on "Profile" in the drawer
    Then I should be on my profile page

  Scenario: navigate to my contacts page
    When I open the drawer
    And I click on "Contacts" in the drawer
    Then I should be on the contacts page

  Scenario: navigate to my settings page
    When I open the drawer
    And I click on "Settings" in the drawer
    Then I should be on my account settings page

  Scenario: navigate to the moderation page
    Given a moderator with email "bob@bob.bob"
    And I sign in as "bob@bob.bob" on the mobile website
    When I open the drawer
    Then I should not see "Admin" within "#drawer"
    And I should see "Reports" within "#drawer"
    When I click on "Reports" in the drawer
    Then I should see "Reports overview" within "#main h1"

  Scenario: navigate to the admin pages
    Given an admin with email "bob@bob.bob"
    And I sign in as "bob@bob.bob" on the mobile website
    When I open the drawer
    Then I should not see "Reports" within "#drawer"
    Then I should not see "Dashboard" within "#drawer"
    When I click on "Admin" in the drawer
    And I click on "Dashboard" in the drawer
    Then I should see "Pod status" within "#main h2"
    When I click on "Admin" in the drawer
    And I click on "User search" in the drawer
    Then I should see "User search" within "#main h3"
    When I click on "Admin" in the drawer
    And I click on "Weekly user stats" in the drawer
    Then I should see "Current server date is " within "#main h2"
    When I click on "Admin" in the drawer
    And I click on "Pod stats" in the drawer
    Then I should see "Usage statistics" within "#main h1"
    When I click on "Admin" in the drawer
    And I click on "Reports" in the drawer
    Then I should see "Reports overview" within "#main h1"
    When I click on "Admin" in the drawer
    And I click on "Pod network" in the drawer
    Then I should see "Pod network" within "#main h2"
    When I click on "Admin" in the drawer
    Then I should see "Sidekiq monitor" within "#drawer"

  Scenario: users doesn't have access to the admin pages
    When I open the drawer
    Then I should not see "Admin" within "#drawer"
    Then I should not see "Reports" within "#drawer"
