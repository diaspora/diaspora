Feature: managing contact requests

  Background: 
    Given I am signed in
    And I have one contact request
    
  Scenario: seeing contact requests
     When I am on the home page
     Then I should see "Manage (1)" in the header

  @javascript @wip
  Scenario: accepting a contact request
    Given I have an aspect called "Family"

    When I am on the home page
    And I follow "Manage (1)"
    Then I should see 1 contact request
    And I should see 0 contacts in "Family"    

    When I drag the contact request to the "Family" aspect
    And I wait for the ajax to finish
    Then I should see 1 contact in "Family"    
