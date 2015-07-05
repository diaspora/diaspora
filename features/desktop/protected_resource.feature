@javascript
# TODO: Add tests for expired access tokens
# TODO: Add tests to check for WWW-Authenticate response header field as according to RFC 6750
Feature: Access protected resources using bearer access token
  Background:
    Given a user with username "bob"
    And I log in manually as "bob" with password "password"
    And I send a post request to the token endpoint using "bob"'s credentials

  Scenario: Valid bearer tokens sent via Authorization Request Header Field
    # TODO: Add tests

  Scenario: Valid bearer tokens sent via Form Encoded Parameter
    # TODO: Add tests

  Scenario: Valid bearer tokens sent via URI query parameter
    When I use received valid bearer tokens to access user info via URI query parameter
    Then I should receive "bob"'s id, username, and email
    # TODO: I want to confirm that the cache-control header in the response is private as according to RFC 6750
    # Unfortunately, selenium doesn't allow access to response headers

  Scenario: Invalid bearer tokens sent via URI query parameter
    When I use invalid bearer tokens to access user info via URI query parameter
    Then I should receive an "invalid_token" error

  Scenario: Valid bearer tokens sent via URI query parameter but user is logged out
    When I log out manually
    And I use received valid bearer tokens to access user info via URI query parameter
    Then I should see "Sign in" in the content
    When I log in manually as "bob" with password "password"
    Then I should receive "bob"'s id, username, and email
