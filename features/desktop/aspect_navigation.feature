@javascript
Feature: Aspect navigation on the left menu
    In order to filter posts visibility and post targeting
    As a diaspora user
    I want to use the aspect navigation menu

    Background:
      Given a user with username "bob"
      And I sign in as "bob@bob.bob"
      And I have an aspect called "Others"

    Scenario: All aspects are selected by default
      When I go to the aspects page
      Then I should see "Besties" aspect selected
      Then I should see "Unicorns" aspect selected
      Then I should see "Others" aspect selected

    Scenario: Aspects selection is remembered through site navigation
      When I select only "Besties" aspect
      Then I should be on the aspects page

      When I go to the stream page
      And I go to the aspects page
      Then I should see "Besties" aspect selected
      And I should see "Unicorns" aspect unselected
      And I should see "Others" aspect unselected

      When I go to the contacts page
      And I go to the aspects page
      Then I should see "Besties" aspect selected
      Then I should see "Unicorns" aspect unselected
      Then I should see "Others" aspect unselected

    Scenario: Aspects selection can include one or more aspects
      When I go to the aspects page
      And I select only "Besties" aspect
      And I select "Unicorns" aspect as well
      Then I should see "Besties" aspect selected
      Then I should see "Unicorns" aspect selected
      Then I should see "Others" aspect unselected

    Scenario: Deselect all aspects
      When I go to the aspects page
      And I follow "Deselect all"
      Then I should see "Besties" aspect unselected
      Then I should see "Unicorns" aspect unselected
      Then I should see "Others" aspect unselected
