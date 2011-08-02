@fails_on_1_9 @rspec2
Feature: HTML formatter
  In order to make it easy to read Cucumber results
  there should be a HTML formatter with an awesome CSS
  
  Scenario: Everything in fixtures/self_test
    When I run cucumber -q --format html --out tmp/a.html features
    Then "fixtures/self_test/tmp/a.html" should have the same contents as "legacy_features/html_formatter/a.html"
