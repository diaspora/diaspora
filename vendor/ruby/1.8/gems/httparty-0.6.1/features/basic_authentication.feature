Feature:  Basic Authentication

  As a developer
  I want to be able to use a service that requires Basic Authentication
  Because that is not an uncommon requirement

  Scenario: Passing no credentials to a page requiring Basic Authentication
    Given a restricted page at '/basic_auth.html'
    When I call HTTParty#get with '/basic_auth.html'
    Then it should return a response with a 401 response code

  Scenario: Passing proper credentials to a page requiring Basic Authentication
    Given a remote service that returns 'Authenticated Page'
    And that service is accessed at the path '/basic_auth.html'
    And that service is protected by Basic Authentication
    And that service requires the username 'jcash' with the password 'maninblack'
    When I call HTTParty#get with '/basic_auth.html' and a basic_auth hash:
       | username | password   |
       | jcash    | maninblack |
    Then the return value should match 'Authenticated Page'
