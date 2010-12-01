Feature: Supports Redirection

  As a developer
  I want to work with services that may redirect me
  And I want it to follow a reasonable number of redirects
  Because sometimes web services do that

  Scenario: A service that redirects once
    Given a remote service that returns 'Service Response'
    And that service is accessed at the path '/landing_service.html'
    And the url '/redirector.html' redirects to '/landing_service.html'
    When I call HTTParty#get with '/redirector.html'
    Then the return value should match 'Service Response'

  # TODO: Look in to why this actually fails...
  Scenario: A service that redirects to a relative URL

  Scenario: A service that redirects infinitely
    Given the url '/first.html' redirects to '/second.html'
    And the url '/second.html' redirects to '/first.html'
    When I call HTTParty#get with '/first.html'
    Then it should raise an HTTParty::RedirectionTooDeep exception
