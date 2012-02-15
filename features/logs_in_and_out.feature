Feature: user authentication

  Scenario: user logs in
    Given a user with username "ohai" and password "secret"
    When I go to the new user session page
    And I fill in "Username" with "ohai"
    And I fill in "Password" with "secret"
    And I press "Sign in"
    Then I should be on the stream page

  @javascript
  Scenario: user logs out
    Given I am signed in
    And I click on my name in the header
    And I follow "Log out"
    Then I should be on the logged out page
    And I should see "Now go mobile."

  Scenario: user uses token auth
    Given a user with username "ohai" and password "secret"
    When I post a photo with a token
    And I go to the stream page
    Then I should be on the new user session page
