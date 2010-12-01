Feature: undefined multiline args

  Scenario: pystring
    Given a pystring
    """
      example
    """

  Scenario: table
    Given a table 
      | table |
      |example|