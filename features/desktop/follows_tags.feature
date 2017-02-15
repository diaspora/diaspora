@javascript
Feature: posting
  In order to take over humanity for the good of society
  As a rock star
  I want to see what humanity is saying about particular tags

  Background:
    Given following users exist:
      | username    | email             |
      | Alice Smith | alice@alice.alice |
      | Bob Jones   | bob@bob.bob       |
    And "bob@bob.bob" has a public post with text "I am da #boss"
    When I sign in as "alice@alice.alice"
    And I go to the tag page for "boss"
    And I press "Follow #boss"
    Then I should see a ".tag-following-action .followed"

  Scenario: can post a message from the tag page
    Then I should see "#boss " in the publisher
    When I click the publisher and post "#boss from the tag page"
    And I go to the tag page for "boss"
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

  Scenario: Go to a tags page with no posts
    When I go to the tag page for "NoPosts"
    Then I should not see any posts in my stream
