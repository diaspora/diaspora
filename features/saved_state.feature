@javascript
Feature: saved state
  Scenario: open aspects persist
    Given I am signed in
      And I have an aspect called "Open 1"
      And I have an aspect called "Closed 1"
      And I have an aspect called "Closed 2"
      And I have an aspect called "Open 2"
     When I follow "Open 1"
      And I follow "Open 2"
     Then I should have aspects "Open 1", "Open 2" open

      And I follow "logout"
     
      And I fill in "Username" with "ohai"
      And I fill in "Password" with "secret"
     Then I should be on the aspects page
     Then I should have aspects "Open 1", "Open 2" open
