Feature: Escaped pipes
  Scenario: They are the future
    Given they have arrived
      | æ | o |
      | a | ø |
    Given they have arrived
      | æ   | \|o |
      | \|a | ø\\ |