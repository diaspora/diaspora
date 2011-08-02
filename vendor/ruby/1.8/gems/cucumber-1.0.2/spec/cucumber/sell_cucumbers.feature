Feature: Sell cucumbers
  As a cucumber farmer
  I want to sell cucumbers
  So that I buy meat

  Scenario: Sell a dozen
    Given there are 5 cucumbers
    When I sell 12 cucumbers
    Then I should owe 7 cucumbers

  Scenario: Sell twenty
    Given there are 5 cucumbers
    When I sell 20 cucumbers
    Then I should owe 15 cucumbers

  Scenario: Sell fifty
    Given there are 5 cucumbers
    When I sell 50 cucumbers
    Then I should owe 45 cucumbers
