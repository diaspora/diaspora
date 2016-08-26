@javascript @mobile
Feature: Visit the landing page of the pod
  In order to find out more about the pod
  As a user
  I want to see the landing page

  Scenario: Visit the home page
    When I am on the root page
    Then I should see "LOG IN"
    When I toggle the mobile view
    And I go to the root page
    Then I should see "Welcome, friend"

    When I am on the root page
    Then I should see "Welcome, friend"
    When I go to the mobile path
    Then I should see "LOG IN"
