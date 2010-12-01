Feature: Be fast

  @fast
  Scenario: Fail if too slow
    # This will start failing if we change the number above 0.5
    When I take 0.2 seconds to complete