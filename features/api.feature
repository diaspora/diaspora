Feature: API
  In order to use a client application
  as an epic developer
  I need to get user's info

  Scenario: Getting a users public profile
    Given a user named "Maxwell S" with email "maxwell@example.com"
    And I send and accept JSON
    When I send a GET request for "/api/v0/users/maxwell_s"
    Then the response status should be "200"
    And the JSON response should have "first_name" with the text "Maxwell"
