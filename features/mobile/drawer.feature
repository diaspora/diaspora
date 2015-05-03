@javascript
Feature: Naviguate between pages using the header menu and the drawer
  As a user
  I want to be able naviguate between the pages of the mobile version

  Background:
    Given following users exist:
      | username     | email             |
      | Bob Jones    | bob@bob.bob       |
      | Alice Smith  | alice@alice.alice |
      
    And I sign in as "alice@alice.alice"
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And I search for "#boss"
    And I press "Follow #boss"
    And I toggle the mobile view
    
  Scenario: naviguate to the stream page
    When I open the drawer
    And I follow "My activity"
    And I click on selector "#header_title"
    Then I should see "There are no posts yet." within "#main_stream"
    
  Scenario: naviguate to the notification page
    When I click on selector "#notification_badge"
    Then I should see "Notifications" within "#main"
    
  Scenario: naviguate to the conversation page
    When I click on selector "#conversations_badge"
    Then I should see "Inbox" within "#main"
    
  Scenario: naviguate to the publisher page
    When I click on selector "#compose_badge"
    Then I should see "All aspects" within "#new_status_message"
    
  Scenario: search a user
    When I open the drawer
    And I search for "Bob"
    Then I should see "Users matching Bob" within "#search_title"
    
  Scenario: search for a tag
    When I open the drawer
    And I search for "#bob"
    Then I should see "#bob" within "#main > h1"
    
  Scenario: naviguate to my activity page
    When I open the drawer
    And I follow "My activity"
    Then I should see "My activity" within "#main"
    
  Scenario: naviguate to my mentions page
    Given Alice has a post mentioning Bob
    And I sign in as "bob@bob.bob"    
    When I open the drawer
    And I follow "@Mentions"
    Then I should see "Bob Jones" within ".stream_element"
    
  Scenario: naviguate to my aspects page
    Given "bob@bob.bob" has a public post with text "bob's text"
    When I open the drawer
    And I follow "My aspects"
    Then I should see "Besties" within "#all_aspects + li > ul"
    And I follow "Besties"
    Then I should see "bob's text" within "#main_stream"
    
  Scenario: naviguate to the followed tags page
    Given "bob@bob.bob" has a public post with text "bob is da #boss"
    When I open the drawer
    And I follow "#Followed tags"
    Then I should see "#boss" within "#followed_tags + li > ul"
    And I follow "#boss"
    Then I should see "bob is da #boss" within "#main_stream"
    
  Scenario: naviguate to my profile page
    When I open the drawer
    And I follow "Profile"
    Then I should see "Alice" within "#author_info"
    
  Scenario: naviguate to my mentions page
    When I open the drawer
    And I follow "Contacts"
    Then I should see "Contacts" within "#main"
    
  Scenario: naviguate to my mentions page
    When I open the drawer
    And I follow "Settings"
    Then I should see "Settings" within "#main"
