Feature: Test::Unit
  In order to please people who like Test::Unit
  As a Cucumber user
  I want to be able to use assert* in my step definitions

  Scenario: assert_equal
    Given x = 5
    And y = 5
    Then I can assert that x == y
