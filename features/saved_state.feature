@javascript
Feature: saved state

  Background:
    Given I sign in
    And I have an aspect called "Closed 1"
    And I have an aspect called "Closed 2"

  Scenario: open aspects persist across sessions
    Given I have an aspect called "Open 1"
    And I have an aspect called "Open 2"
    And I go to the aspects page

    When I follow "Open 1"
    And I follow "Open 2"
    Then aspect "Open 1" should be selected
    And aspect "Open 2" should be selected
    But aspect "Closed 1" should not be selected
    And aspect "Closed 2" should not be selected

    When I sign out
    And I sign in
    Then I should be on the aspects page
    And aspect "Open 1" should be selected
    And aspect "Open 2" should be selected
    But aspect "Closed 1" should not be selected
    And aspect "Closed 2" should not be selected

    When I follow "All Aspects"
    Then aspect "All Aspects" should be selected

  Scenario: home persists across sessions
    Given I am on the aspects page

    When I follow "Closed 1"
    And I follow "All Aspects"
    Then aspect "All Aspects" should be selected
    But aspect "Closed 1" should not be selected
    And aspect "Closed 2" should not be selected

    When I sign out
    And I sign in
    Then I should be on the aspects page
    And aspect "All Aspects" should be selected
    But aspect "Closed 1" should not be selected
    And aspect "Closed 2" should not be selected
