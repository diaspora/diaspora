@javascript
Feature: posting
  In order to take over humanity for the good of society
  As a rock star
  I want to see what humanity is saying about particular tags

  Background:
    Given following users exist:
      | username   |
      | bob        |
      | alice      |

    When I sign in as "bob@bob.bob"
    And I post a status with the text "I am da #boss"
    When I sign out
    And I sign in as "alice@alice.alice"
    And I search for "#boss"
    And I press "Follow #boss"

  Scenario: can post a message from the tag page
    Then I should see "#boss" within "#publisher"
    And I click the publisher and post "#boss from the tag page"
    And I search for "#boss"
    Then I should see "#boss from the tag page"

  Scenario: see a tag that I am following
    When I go to the home page
    And I follow "#boss"
    Then I should see "I am da #boss" within "body"

  Scenario: see a tag that I am following and I post over there
    When I go to the home page
    And I follow "#boss"
    And I click the publisher and post "#boss from the #boss tag page"
    Then I should see "#boss from the #boss tag page" within "body"

  Scenario: can stop following a tag from the tag page
    When I press "Following #boss"
    And I go to the followed tags stream page
    Then I should not see "#boss" within "#tags_list"

  Scenario: can stop following a tag from the homepage
    When I go to the followed tags stream page
    And I unfollow the "boss" tag
    Then I should not see "#tag-following-boss" within "#tags_list"
