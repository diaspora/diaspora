Feature: Outlines
  In order to re-use scenario table values
  As a citizen of Cucumbia
  I want to explicitly mark the parameters in a scenario outline

  Scenario Outline: controlling order
    Given there are <start> cucumbers
    When I eat <eat> cucumbers
    Then I should have <left> cucumbers

  Examples:
    | left  | start  | eat  |
    |  7    |  12    |  5   |
    |  15   |  20    |  5   |
    
  Scenario Outline: reusing place holder
    Given there are <start> cucumbers
    When I eat <eat> cucumbers
    Then I should have <left> cucumbers
    And I should have <eat> cucumbers in my belly

  Examples: Lots of cukes
    | start  | eat  | left |
    |  12    |  5   |  7   |
    |  20    |  5   |  15  |

  Examples: Ridiculous amounts of cukes
    | start  | eat  | left |
    |  120    |  50   |  70   |
    |  200    |  50   |  150  |
  
  Scenario Outline: no placeholders
    Given there are 12 cucumbers
    When I eat 5 cucumbers
    Then I should have 7 cucumbers

  Examples:
    | start  | eat  | left |
    |  12    |  5   |  7   |
    |  20    |  5   |  15  |
  
  Scenario Outline: using '<' and '>' not as placeholder
    Given the belly space is < 12 and > 6
    And there are <start> cucumbers
    When I eat <eat> cucumbers
    Then I should have <left> cucumbers

  Examples:
    | start  | eat  | left |
    |  12    |  5   |  7   |
    |  20    |  5   |  15  |

  Scenario Outline: with step tables
    Given I have the following fruits in my pantry
      |    name     | quantity |
      | cucumbers   |    10    |
      | strawberrys |    5     |
      | apricots    |    7     |

    When I eat <number> <fruits> from the pantry
    Then I should have <left> <fruits> in the pantry

    Examples:
      | number |   fruits   | left |
      |   2    | cucumbers  |  8   |
      |   4    | strawberrys|  1   |
      |   2    | apricots   |  5   |

  Scenario Outline: placeholder in a multiline string
    Given my shopping list
      """
        Must buy some <fruits>
      """
    Then my shopping list should equal
      """
        Must buy some cucumbers
      """
    
    Examples:
      |  fruits   |
      | cucumbers |

  Scenario Outline: placeholder in step table
    Given I have the following fruits in my pantry
      |    name     | quantity      |
      | cucumbers   | <quant_cukes> |
      | strawberrys | <quant_straw> |

    When I eat <number> <fruits> from the pantry
    Then I should have <left> <fruits> in the pantry

    Examples:
      | quant_cukes | quant_straw | number |   fruits    | left |
      | 10          | 5           |   2    | cucumbers   |  8   |
      | 5           | 5           |   4    | strawberrys |  1   |
