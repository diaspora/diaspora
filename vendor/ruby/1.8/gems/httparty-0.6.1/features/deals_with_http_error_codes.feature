Feature: Deals with HTTP error codes

  As a developer
  I want to be informed of non-successful responses
  Because sometimes thing explode
  And I should probably know what happened

  Scenario: A response of '404 - Not Found'
    Given a remote service that returns a 404 status code
    And that service is accessed at the path '/404_service.html'
    When I call HTTParty#get with '/404_service.html'
    Then it should return a response with a 404 response code

  Scenario: A response of '500 - Internal Server Error'
    Given a remote service that returns a 500 status code
    And that service is accessed at the path '/500_service.html'
    When I call HTTParty#get with '/500_service.html'
    Then it should return a response with a 500 response code

  Scenario: A non-successful response where I need the body
    Given a remote service that returns a 400 status code
    And the response from the service has a body of 'Bad response'
    And that service is accessed at the path '/400_service.html'
    When I call HTTParty#get with '/400_service.html'
    Then it should return a response with a 400 response code
    And the return value should match 'Bad response'
