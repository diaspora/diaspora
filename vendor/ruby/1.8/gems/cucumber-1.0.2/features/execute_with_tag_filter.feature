Feature: Tag logic
  In order to conveniently run subsets of features
  As a Cuker
  I want to select features using logical AND/OR of tags

  Background:
    Given a file named "features/tagulicious.feature" with:
      """
      Feature: Sample

        @one @three
        Scenario: Example
          Given passing

        @one
        Scenario: Another Example
          Given passing

        @three
        Scenario: Yet another Example
          Given passing

        @ignore
        Scenario: And yet another Example
      """

  Scenario: ANDing tags
    When I run `cucumber -q -t @one -t @three features/tagulicious.feature`
    Then it should pass with:
      """
      Feature: Sample

        @one @three
        Scenario: Example
          Given passing

      1 scenario (1 undefined)
      1 step (1 undefined)

      """

  Scenario: ORing tags
    When I run `cucumber -q -t @one,@three features/tagulicious.feature`
    Then it should pass with:
      """
      Feature: Sample

        @one @three
        Scenario: Example
          Given passing

        @one
        Scenario: Another Example
          Given passing

        @three
        Scenario: Yet another Example
          Given passing

      3 scenarios (3 undefined)
      3 steps (3 undefined)

      """
