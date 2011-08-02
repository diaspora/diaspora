Feature: undefined multiline args

  Scenario: pystring
    Given a pystring
    """
      example with <html> entities
    """

  Scenario: table
    Given a table 
      | table |
      |example|