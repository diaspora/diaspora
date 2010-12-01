Feature: Handles Multiple Formats

  As a developer
  I want to be able to consume remote services of many different formats
  And I want those formats to be automatically detected and handled
  Because web services take many forms
  And I don't want to have to do any extra work

  Scenario: An HTML service
    Given a remote service that returns '<h1>Some HTML</h1>'
    And that service is accessed at the path '/html_service.html'
    And the response from the service has a Content-Type of 'text/html'
    When I call HTTParty#get with '/html_service.html'
    Then it should return a String
    And the return value should match '<h1>Some HTML</h1>'

  Scenario: A JSON service
    Given a remote service that returns '{ "jennings": "waylon", "cash": "johnny" }'
    And that service is accessed at the path '/service.json'
    And the response from the service has a Content-Type of 'application/json'
    When I call HTTParty#get with '/service.json'
    Then it should return a Hash equaling:
       | key      | value  |
       | jennings | waylon |
       | cash     | johnny |

  Scenario: An XML Service
    Given a remote service that returns '<singer>waylon jennings</singer>'
    And that service is accessed at the path '/service.xml'
    And the response from the service has a Content-Type of 'text/xml'
    When I call HTTParty#get with '/service.xml'
    Then it should return a Hash equaling:
       | key    | value           |
       | singer | waylon jennings |
