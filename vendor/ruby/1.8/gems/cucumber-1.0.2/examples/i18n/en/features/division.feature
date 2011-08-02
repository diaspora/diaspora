# language: en
Feature: Division
  In order to avoid silly mistakes
  Cashiers must be able to calculate a fraction

  Scenario: Regular numbers
    * I have entered 3 into the calculator
    * I have entered 2 into the calculator
    * I press divide
    * the result should be 1.5 on the screen
