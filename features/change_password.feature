@javascript
Feature: Change password

  Scenario: Change my password
  	Given I am signed in
    And I click on my name in the header
    And I follow "settings"
    Then I should be on my account settings page
    When I put in my password in "user_current_password" 
    And I fill in "user_password" with "newsecret"
    And I fill in "user_password_confirmation" with "newsecret"
    And I press "Change Password"
    Then I should see "Password Changed"  
    When I sign out
    Then I should be on the home page    
    And I sign in with password "newsecret"
    Then I should be on the aspects page
