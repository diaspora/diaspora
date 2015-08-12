@javascript
Feature: Access protected resources using auth code flow
  Background:
    Given a user with username "kent"

  Scenario: Invalid client id to auth endpoint
    When I register a new client
    And I send a post request from that client to the code flow authorization endpoint using a invalid client id
    And I sign in as "kent@kent.kent"
    Then I should see an "bad_request" error

  Scenario: Application is denied authorization
    When I register a new client
    And I send a post request from that client to the code flow authorization endpoint
    And I sign in as "kent@kent.kent"
    And I deny authorization to the client
    Then I should not see any tokens in the redirect url

  Scenario: Application is authorized
    When I register a new client
    And I send a post request from that client to the code flow authorization endpoint
    And I sign in as "kent@kent.kent"
    And I give my consent and authorize the client
    And I parse the auth code and create a request to the token endpoint
    And I parse the tokens and use it obtain user info
    Then I should receive "kent"'s id, username, and email
