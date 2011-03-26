Feature: managing contact requests

  Background: 
    Given I am signed in
    And I have an aspect called "Family"
    And I have one contact request
    
  Scenario: seeing contact request notifications
    When I am on the home page
    Then I should see "All aspects" in the header
    Then I should see "All aspects" in the header
    When I follow "All aspects"
    Then I should see "new request!"
    
  @javascript
  Scenario: viewing a requests profile
    When I am on the manage aspects page
    When I click on the contact request
    And I wait for "the requestors profile" to load
    Then I should be on the requestors profile
    And I should see "wants to share with you"

  @javascript
  Scenario: accepting a contact request
    When I am on the home page
    And I follow "new request!"
    Then I should see 0 contacts in "Family"

    When I drag the contact request to the "Family" aspect
    And I wait for the ajax to finish
    Then I should see 1 contact in "Family"

  @javascript @wip
  Scenario: ignoring a contact request
    When I am on the aspects manage page
    Then I should see 1 contact request
    When I click "X" on the contact request
    And I wait for the ajax to finish
    Then I should see 0 contact requests
