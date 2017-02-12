@aspects @javascript
Feature: User manages contacts
  In order to share with a limited group
  As a User
  I want to create new aspects

  Scenario: creating an aspect from contacts index
    Given I am signed in
    And I am on the contacts page
    And I follow "Add an aspect"
    And I fill in "aspect_name" with "Dorm Mates" in the aspect creation modal
    And I click on selector ".btn-primary" in the aspect creation modal
    Then I should see "Dorm Mates" within "#aspect_nav"

  Scenario: creating an aspect from homepage
    Given I am signed in
    And I go to the aspects page
    When I follow "Add an aspect"
    And I fill in "aspect_name" with "losers" in the aspect creation modal
    And I click on selector ".btn-primary" in the aspect creation modal
    Then I should be on the contacts page
    And I should see "losers" within "#aspect_nav"

  Scenario: deleting an aspect from contacts index
    Given I am signed in
    And I have an aspect called "People"
    When I am on the contacts page
    And I follow "People"
    And I confirm the alert after I click on selector "#delete_aspect"
    Then I should be on the contacts page
    And I should not see "People" within "#aspect_nav"

  Scenario: deleting an aspect from homepage
    Given I am signed in
    And I have an aspect called "People"
    When I am on the aspects page
    And I click on "People" aspect edit icon
    And I confirm the alert after I click on selector "#delete_aspect"
    Then I should be on the contacts page
    And I should not see "People" within "#aspect_nav"

  Scenario: Editing the aspect memberships of a contact from the contacts page
    Given I am signed in
    And I have 2 contacts
    And I have an aspect called "Cat People"
    When I am on the contacts page
    And I follow "Cat People"
    And I add the first person to the aspect
    Then I should have 1 contact in "Cat People"

    When I remove the first person from the aspect
    Then I should have 0 contacts in "Cat People"

  Scenario: Renaming an aspect
    Given I am signed in
    And I have an aspect called "Cat People"
    When I am on the contacts page
    And I follow "Cat People"
    And I click on selector "#change_aspect_name"
    And I fill in "aspect_name" with "Unicorn People"
    And I press "Update"
    Then I should see "Unicorn People" within "#aspect_name"

  Scenario: sorting the aspects
    Given I am signed in
    And I have an aspect called "People"
    And I have an aspect called "Cat People"
    When I am on the contacts page
    And I have turned off jQuery effects
    And I drag "Cat People" up
    Then I should see "Cat People" as 2. aspect
    And I should see "People" as 3. aspect
    When I go to the contacts page
    Then I should see "Cat People" as 2. aspect
    And I should see "People" as 3. aspect
