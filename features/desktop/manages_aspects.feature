@aspects @javascript
Feature: User manages contacts
  In order to share with a limited group
  As a User
  I want to create new aspects

  Scenario: creating an aspect from contacts index
    Given I am signed in
    And I am on the contacts page
    And I follow "+ Add an aspect"
    And I fill in "Name" with "Dorm Mates" in the modal window
    And I press "Create" in the modal window
    Then I should see "Dorm Mates" within "#aspect_nav"

  Scenario: creating an aspect from homepage
    Given I am signed in
    And I go to the aspects page
    When I follow "Add an aspect"
    And I fill in "Name" with "losers" in the modal window
    And I press "Create" in the modal window
    Then I should see "losers" within "#aspect_nav"

  Scenario: deleting an aspect from contacts index
    Given I am signed in
    And I have an aspect called "People"
    When I am on the contacts page
    And I follow "People"
    And I follow "add contacts to People"
    And I press "Delete" in the modal window
    And I confirm the alert
    Then I should be on the contacts page
    And I should not see "People" within "#aspects_list"

  Scenario: deleting an aspect from homepage
    Given I am signed in
    And I have an aspect called "People"
    When I am on the aspects page
    And I click on "People" aspect edit icon
    And I follow "Delete" within "#aspect_controls"
    And I confirm the alert
    Then I should be on the contacts page
    And I should not see "People" within "#aspects_list"

  Scenario: Editing the aspect memberships of a contact from the aspect edit facebox
    Given I am signed in
    And I have 2 contacts
    And I have an aspect called "Cat People"
    When I am on the contacts page
    And I follow "Cat People"
    And I follow "add contacts to Cat People"
    And I check the first contact list button
    Then I should have 1 contact in "Cat People"

    When I uncheck the first contact list button
    Then I should have 0 contacts in "Cat People"
    
  Scenario: Renaming an aspect
    Given I am signed in
    And I have an aspect called "Cat People"
    When I am on the contacts page
    And I follow "Cat People"
    And I follow "Manage" within "#aspect_controls"
    And I follow "rename"
    And I fill in "aspect_name" with "Unicorn People"
    And I press "update"
    Then I should see "Unicorn People" within "#aspect_name_title"

  Scenario: infinite scroll on contacts index
    Given I am signed in
    And I resize my window to 800x600
    And I have 30 contacts
    And I am on the contacts page
    Then I should see 25 contacts

    When I scroll down
    Then I should see 30 contacts

  Scenario: clicking on the contacts link in the header with zero contacts directs a user to the featured users page
    Given I am signed in
    And I have 0 contacts
    And I am on the home page

    And I click on my name in the header
    When I follow "Contacts"
    Then I should see "Community Spotlight" within ".span9"

  Scenario: clicking on the contacts link in the header with contacts does not send a user to the featured users page
    Given I am signed in
    And I have 2 contacts
    And I am on the home page

    And I click on my name in the header
    When I follow "Contacts"
    Then I should not see "Community Spotlight" within ".span9"
