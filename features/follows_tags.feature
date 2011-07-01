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


  Scenario: see a tag that I am following
    Given I expand the publisher
    And I fill in "status_message_fake_text" with "I am ALICE"
    And I press the first ".public_icon" within "#publisher"
    And I press "Share"
    And I go to the destroy user session page

    And I sign in as "alice@alice.alice"
    And I search for "#alice"
    And I press "Follow #alice"
    And I go to the home page
    And I press "#alice"
    Then I should see "I am #alice"





