@javascript
Feature: posting
  In order to takeover humanity for the good of society
  As a rock star
  I want to see what humanity is saying about particular tags

  Background:
    Given a user with username "bob"
    And a user with username "alice"
    When I sign in as "bob@bob.bob"

    And I post a status with the text "I am da #boss"
    And I am on the home page

    Then I should see "I am da #boss"


    And I go to the destroy user session page

    And I sign in as "alice@alice.alice"
    And I search for "#boss"
    And I press "Follow #boss"
    And I wait for the ajax to finish

  Scenario: see a tag that I am following
    When I go to the home page
    And I follow "#boss"
    Then I should see "I am da #boss"

  Scenario: can stop following a particular tag
    When I hover over the ".button.tag_following"
    When I press "Stop Following #boss"

    And I go to the home page
    Then I should not see "#boss" within ".left_nav"

  Scenario:
    When I go to the home page
    And I preemptively confirm the alert
    And I hover over the "li.unfollow#boss"
    And I follow "unfollow_boss"
    And I wait for the ajax to finish
    Then I should not see "#boss" within ".left_nav"
