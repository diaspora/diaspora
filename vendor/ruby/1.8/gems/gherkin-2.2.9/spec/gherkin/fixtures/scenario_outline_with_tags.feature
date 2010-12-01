Feature: Bug 67

  @wip
  Scenario Outline: WIP
    When blah

    Examples:
      | a |
      | b |
      | c |

  Scenario: Not WIP
    When blah
