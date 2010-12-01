Feature: Supports the timeout option
  In order to handle inappropriately slow response times
  As a developer
  I want my request to raise an exception after my specified timeout as elapsed

  Scenario: A long running response
    Given a remote service that returns '<h1>Some HTML</h1>'
    And that service is accessed at the path '/long_running_service.html'
    And that service takes 2 seconds to generate a response
    When I set my HTTParty timeout option to 1
    And I call HTTParty#get with '/long_running_service.html'
    Then it should raise a Timeout::Error exception
    And I wait for the server to recover
