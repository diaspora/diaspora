Feature: sending and receiving requests

  Background: 
    Given a user with email "bob@bob.bob"
    And a user with email "alice@alice.alice"
    
  @javascript
  Scenario: initiating and accepting a contact request
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I press the first ".share_with.button" within "#author_info"
    And I press the first ".add.button" within "#facebox #aspects_list ul > li:first-child"
    And I wait for the ajax to finish
    Then I should see a ".added.button" within "#facebox #aspects_list ul > li:first-child"
    Then I go to the destroy user session page

    When I sign in as "alice@alice.alice"
    And I am on the aspects manage page
    Then I should see 1 contact request
    When I drag the contact request to the "Besties" aspect
    And I wait for the ajax to finish
    Then I should see 1 contact in "Besties"

    When I go to the home page
    Then I go to the aspects manage page
    Then I should see 1 contact in "Besties"
    Then I go to the destroy user session page

    When I sign in as "bob@bob.bob"
    And I am on the aspects manage page
    Then I should see 1 contact in "Besties"

