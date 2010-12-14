Feature: sending and receiving requests

  Background: 
    Given a user with email "bob@bob.bob"
    And a user with email "alice@alice.alice"
    
  @javascript
  Scenario: initiating and accepting a contact request
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I press "add contact"
    And I wait for the ajax to finish
    Then I should see "sent!"
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

