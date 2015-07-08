Feature: Access protected resources using password flow
  Background:
    Given a user with username "kent"

  Scenario: Invalid credentials to token endpoint
    When I register a new client
    And I send a post request from that client to the token endpoint using invalid credentials
    Then I should receive an "invalid_grant" error

  Scenario: Invalid bearer tokens sent
    When I register a new client
    And I send a post request from that client to the token endpoint using "kent"'s credentials
    And I use invalid bearer tokens to access user info
    Then I should receive an "invalid_token" error

  Scenario: Valid password flow
    When I register a new client
    And I send a post request from that client to the token endpoint using "kent"'s credentials
    And I use received valid bearer tokens to access user info
    Then I should receive "kent"'s id, username, and email
