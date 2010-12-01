Feature:  Digest Authentication

  As a developer
  I want to be able to use a service that requires Digest Authentication
  Because that is not an uncommon requirement

  Scenario: Passing no credentials to a page requiring Digest Authentication
    Given a restricted page at '/digest_auth.html'
    When I call HTTParty#get with '/digest_auth.html'
    Then it should return a response with a 401 response code

  Scenario: Passing proper credentials to a page requiring Digest Authentication
    Given a remote service that returns 'Digest Authenticated Page'
    And that service is accessed at the path '/digest_auth.html'
    And that service is protected by Digest Authentication
    And that service requires the username 'jcash' with the password 'maninblack'
    When I call HTTParty#get with '/digest_auth.html' and a digest_auth hash:
       | username | password   |
       | jcash    | maninblack |
    Then the return value should match 'Digest Authenticated Page'
