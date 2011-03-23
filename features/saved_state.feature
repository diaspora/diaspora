@javascript
Feature: saved state
  Scenario: open aspects persist across sessions
    Given I am signed in
      And I have an aspect called "Open 1"
      And I have an aspect called "Closed 1"
      And I have an aspect called "Closed 2"
      And I have an aspect called "Open 2"
      And I am on the aspects page
     When I follow "Open 1"
      And I follow "Open 2"

      Then I should have aspect "Open 1" "selected"
      Then I should have aspect "Open 2" "selected"
      Then I should have aspect "Closed 1" "not selected"
      Then I should have aspect "Closed 2" "not selected"

      And I click on my name in the header
      And I follow "logout"

      And I go to the new user session page
     
      And I am signed in

      Then I should be on the aspects page
      Then I should have aspect "Open 1" "selected"
      But I should have aspect "Open 2" "selected"
      But I should have aspect "Closed 1" "not selected"
      But I should have aspect "Closed 2" "not selected"

      And I follow "All aspects"
      Then I should have aspect "All aspects" "selected"

  Scenario: home persists across sessions
    Given I am signed in
      And I have an aspect called "Closed 1"
      And I have an aspect called "Closed 2"
      And I am on the aspects page
     When I follow "Closed 1"
     When I follow "All aspects"

      Then I should have aspect "All aspects" "selected"
      Then I should have aspect "Closed 1" "not selected"
      Then I should have aspect "Closed 2" "not selected"

      And I click on my name in the header
      And I follow "logout"

      And I go to the new user session page
     
      And I am signed in

      Then I should be on the aspects page
      Then I should have aspect "All aspects" "selected"
      Then I should have aspect "Closed 1" "not selected"
      Then I should have aspect "Closed 2" "not selected"
