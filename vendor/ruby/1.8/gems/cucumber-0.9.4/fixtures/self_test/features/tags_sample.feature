@sample_one
Feature: Tag samples

  @sample_two @sample_four
  Scenario: Passing
    Given missing

  @sample_three
  Scenario Outline:
    Given <state>
  Examples:
    |state|
    |missing|

  @sample_three @sample_four
  Scenario: Skipped
    Given missing