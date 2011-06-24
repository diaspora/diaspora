@aspects @javascript
Feature: User manages contacts
  In order to share with a limited group
  As a User
  I want to create new aspects

  Scenario: creating an aspect from contacts index
    Given I am signed in
    When I follow "All Aspects" in the header
    And I follow "Your Contacts"
    And I follow "+ Add a new aspect"
    And I fill in "Name" with "Dorm Mates" in the modal window
    And I press "Create" in the modal window
    Then I should see "Dorm Mates" in the header
    
  Scenario: creating an aspect from homepage
    Given I am signed in
    When I follow "All Aspects" in the header
    And I follow "+" in the header
    And I fill in "Name" with "losers" in the modal window
    And I press "Create" in the modal window
    Then I should see "losers" in the header

  Scenario: Editing the aspect memberships of a contact from the 'sharers' facebox
    Given I am signed in
    And I have 2 contacts
    And I have an aspect called "Cat People"
    When I follow "All Aspects" in the header
    And I follow "2 contacts" within "#sharers"
    And I wait for the ajax to finish
    And I press the first ".toggle.button"
    And I press the 2nd "li" within ".dropdown.active .dropdown_list"
    And I wait for the ajax to finish
    Then I should have 1 contact in "Cat People"

    When I press the 2nd "li" within ".dropdown.active .dropdown_list"
    And I wait for the ajax to finish
    Then I should have 0 contacts in "Cat People"

