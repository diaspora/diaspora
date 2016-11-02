@javascript @mobile
Feature: Navigate between pages using the header menu and the drawer
  As a user
  I want to be able navigate between the pages of the mobile version

  Background:
    Given following users exist:
      | username     | email             |
      | Bob Jones    | bob@bob.bob       |
      | Alice Smith  | alice@alice.alice |

    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And I sign in as "alice@alice.alice" on the mobile website

  Scenario: navigate to the stream page
    When I go to the activity stream page
    And I click on selector "#header-title"
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

  Scenario: navigate to my aspects page
    Given "bob@bob.bob" has a public post with text "bob's text"
    When I open the drawer
    And I click on "My aspects" in the drawer
    And I click on "Besties" in the drawer
    Then I should see "bob's text" within "#main_stream"

  Scenario: navigate to the followed tags page
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
