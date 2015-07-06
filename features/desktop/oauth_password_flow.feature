@javascript
Feature: Access protected resources using password flow
  # TODO: Add tests for expired access tokens
  Background:
    Given a user with username "kent"

  Scenario: Valid bearer tokens sent via Authorization Request Header Field

  Scenario: Valid bearer tokens sent via Form Encoded Parameter

  Scenario: Valid bearer tokens sent via URI query parameter
    When I send a post request to the token endpoint using "kent"'s credentials
    And I use received valid bearer tokens to access user info via URI query parameter
    Then I should receive "kent"'s id, username, and email

  Scenario: Invalid bearer tokens sent via URI query parameter
    When I send a post request to the token endpoint using "kent"'s credentials
    And I use invalid bearer tokens to access user info via URI query parameter
    Then I should receive an "invalid_token" error
