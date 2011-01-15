@javascript
Feature: Close Account
 In order to close an existing account
 As a user
 I want to sign in, close my account and try to log in again

  Scenario: user closes account
    Given a user with username "ohai" and password "secret"
    When I go to the new user session page
    And I fill in "Username" with "ohai"
    And I fill in "Password" with "secret"
    And I press "Sign in"
    Then I should be on the aspects page

    When I click on my name in the header
    And I follow "account settings"    
    And I click ok in the confirm dialog to appear next
    And I follow "Close Account"
    Then I should be on the home page
    
    When I go to the new user session page
    And I fill in "Username" with "ohai"
    And I fill in "Password" with "secret"
    And I press "Sign in"
    #Then I should not be on the aspects page
    Then I should be on the new user session page
    And I wait for the ajax to finish
    Then I should see "Invalid email or password."
