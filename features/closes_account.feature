@javascript
Feature: Close Account
 In order to close an existing account
 As a user
 I want to sign in, close my account and try to log in again

  Scenario: user closes account
    Given I am signed in
    When I click on my name in the header
    And I follow "account settings"    
    And I click ok in the confirm dialog to appear next
    And I follow "Close Account"
    Then I should be on the home page
    
    When I go to the new user session page
    And I try to sign in
    Then I should be on the new user session page
    When I wait for the ajax to finish
    Then I should see "Invalid email or password."
