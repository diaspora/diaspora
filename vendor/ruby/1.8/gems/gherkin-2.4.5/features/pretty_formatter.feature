Feature: Pretty Formatter
  In order to have pretty gherkin
  I want to verify that all prettified cucumber features parse OK

  Scenario: Parse all the features in Cucumber
    Given I have Cucumber's source code next to Gherkin's
    And I find all of the .feature files
    When I send each prettified original through the "pretty" machinery
    Then the machinery output should be identical to the prettified original

  Scenario: Parse all the features in Cucumber with JSON
    Given I have Cucumber's source code next to Gherkin's
    And I find all of the .feature files
    When I send each prettified original through the "json" machinery
    Then the machinery output should be identical to the prettified original
