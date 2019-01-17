@javascript
Feature: user authentication

  Scenario: user logs in
    Given a user with username "ohai" and password "secret"
    When I sign in manually as "ohai" with password "secret"
    Then I should be on the stream page

  Scenario: user logs in with 2fa enabled
    Given a user with username "ohai" and password "secret" activated 2fa
    When I sign in manually as "ohai" with password "secret"
    Then I should be on the 2fa page
    When I enter an incorrect 2fa token
    Then I should be on the 2fa page
    When I enter a correct 2fa token
    Then I should be on the stream page

  Scenario: user logs out
    Given I am signed in
    And I click on my name in the header
    And I follow "Log out"
    Then I should be on the new user session page
