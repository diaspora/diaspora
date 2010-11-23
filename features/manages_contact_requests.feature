Feature: managing contact requests

  Background: 
    Given I am signed in
    And I have an aspect called "Family"
    And I have one contact request
    
  Scenario: seeing contact requests
    When I am on the home page
    Then I should see "Home (1)" in the header

  @javascript
  Scenario: accepting a contact request
    When I am on the home page
    And I follow "Home (1)"
    Then I should see "1 new request!" 
    And I should see 0 contacts in "Family"    

    When I am on the home page
    Then I follow "1 new request!"
		And I drag the contact request to the "Family" aspect
    And I wait for the ajax to finish
    Then I should see 1 contact in "Family"

  @javascript @wip
  Scenario: ignoring a contact request
    When I am on the aspects manage page
    Then I should see 1 contact request
    When I click "X" on the contact request
    And I wait for the ajax to finish
    Then I should see 0 contact requests
