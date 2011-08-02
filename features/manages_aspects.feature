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
    When I follow "Add an aspect"
    And I fill in "Name" with "losers" in the modal window
    And I press "Create" in the modal window
    Then I should see "losers" within "#aspect_nav"

  Scenario: Editing the aspect memberships of a contact from the aspect edit facebox
    Given I am signed in
    And I have 2 contacts
    And I have an aspect called "Cat People"
    When I am on the contacts page
    And I follow "Cat People"
    And I follow "Edit Cat People"
    And I wait for the ajax to finish
    And I press the first ".contact_list .button"
    And I wait for the ajax to finish
    Then I should have 1 contact in "Cat People"

    When I press the first ".contact_list .button"
    And I wait for the ajax to finish
    Then I should have 0 contacts in "Cat People"

  Scenario: scrolling through contacts index
    Given I am signed in
    And I have 60 contacts
    And I am on the contacts page
    Then I should see 25 contacts

    When I scroll down
    Then I should see 50 contacts

    When I scroll down
    Then I should see 60 contacts


  Scenario: clicking on the contacts link in the header with zero contacts directs a user to the featured users page
    Given I am signed in
    And I have 0 contacts
    And I am on the home page

    When I follow "Contacts"
    Then I should see "Featured Users" within ".span-18"

  Scenario: clicking on the manage aspects link in the right nav with zero contacts directs a user to the featured users page
    Given I am signed in
    And I have 0 contacts
    And I am on the home page

    When I follow "Manage your aspects."
    Then I should see "Featured Users" within ".span-18"

  Scenario: clicking on the contacts link in the header with contacts does not send a user to the featured users page
    Given I am signed in
    And I have 2 contacts
    And I am on the home page

    When I follow "Contacts"
    Then I should not see "Featured Users" within "#section_header"
