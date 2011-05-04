Feature: user authentication

  Scenario: user logs in
    Given a user with username "ohai" and password "secret"
    When I go to the new user session page
    And I fill in "Username" with "ohai"
    And I fill in "Password" with "secret"
    And I press "Sign in"
    Then I should be on the aspects page

  @javascript
  Scenario: user logs out
    Given I am signed in
    And I click on my name in the header
    And I follow "log out"
    Then I should be on the home page
