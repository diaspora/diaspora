@javascript
Feature: posting
  In order to takeover humanity for the good of society
  As a rock star
  I want to see what humanity is saying about particular tags

  Background:
    Given a user with username "bob"
    And a user with username "alice"
    When I sign in as "bob@bob.bob"
    And I am on the home page

    And I expand the publisher
    And I fill in "status_message_fake_text" with "I am da #boss"
    And I press the first ".public_icon" within "#publisher"
    And I press "Share"
    And I wait for the ajax to finish
    And I wait for the ajax to finish

    #the following (3 lines) verbosity should not be needed
    When I go to the home page
    Then I should see "I am da #boss"
    And I wait for 5 seconds

    And I follow "#boss"
    And I wait for the ajax to finish
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
    Then I should see "Stop Following #boss"
    When I go to the home page
    And I should not see "#boss" in ".left_nav"



