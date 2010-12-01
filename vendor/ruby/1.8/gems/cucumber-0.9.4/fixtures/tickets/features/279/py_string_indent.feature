Feature: pystring indentaion testcase

  Scenario: example of correct indentation
    Given multiline string
         """
           I'm a cucumber and I'm ok
         I sleep all night and test all day
         """
    Then string is
      """
        I'm a cucumber and I'm ok
      I sleep all night and test all day
      """						      

  Scenario: example of wrong indentation
    Given I am in tickets/features/279
    When I run cucumber -q wrong.feature_
    Then it should fail with
      """

      """
    And STDERR should match
      """
      wrong.feature_:8:10: Parse error
      """
