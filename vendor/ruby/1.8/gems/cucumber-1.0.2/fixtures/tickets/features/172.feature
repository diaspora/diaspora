Feature: Login
  To ensure the safety of the application
  A regular user of the system
  Must authenticate before using the app


  Scenario Outline: Failed Login
    Given the user "known_user"

    When I go to the main page
    Then I should see the login form

    When I fill in "login" with "<login>"
    And I fill in "password" with "<password>"
    And I press "Log In"
    Then the login request should fail
    And I should see the error message "Login or Password incorrect"

    Examples:
      | login        | password       |
      |              |                |
      | unknown_user |                |
      | known_user   |                |
      |              | wrong_password |
      |              | known_userpass |
      | unknown_user | wrong_password |
      | unknown_user | known_userpass |
      | known_user   | wrong_password |
