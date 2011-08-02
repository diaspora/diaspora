@intentional_failure
Feature: Tables
  Scenario: Extra row with table
    Then the table should be different with table:
      | a     | b    |
      | one   | two  |
      | three | four |

  Scenario: Extra row and missing column with table
    Then the table should be different with table:
      | a     | e | b    |
      | one   | Q | two  |
      | three | R | four |
