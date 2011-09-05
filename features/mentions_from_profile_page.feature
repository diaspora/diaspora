@javascript
Feature: mentioning a contact from their profile page
    In order to enlighten humanity for the good of society
    As a rock star
    I want to mention someone I think is cool

    Background:
      Given I am on the home page
      And a user with username "bob"
      And a user with username "alice"

      When I sign in as "bob@bob.bob"
      And a user with username "bob" is connected with "alice"
      And I have an aspect called "PostTo"
      And I have an aspect called "DidntPostTo"
      And I have user with username "alice" in an aspect called "PostTo"
      And I have user with username "alice" in an aspect called "DidntPostTo"

      And I am on the home page

    Scenario: mentioning while posting to all aspects
      Given I am on "alice@alice.alice"'s page
      And I have turned off jQuery effects
      And I click "Mention" button
      And I expand the publisher in the modal window
      And I append "I am eating a yogurt" to the publisher
      And I press "Share" in the modal window

      When I am on the aspects page
      And I follow "PostTo" within "#aspect_nav"
      Then I should see "I am eating a yogurt"

      When I am on the aspects page
      And I follow "DidntPostTo" within "#aspect_nav"
      Then I should see "I am eating a yogurt"

    Scenario: mentioning while posting to just one aspect
      Given I am on "alice@alice.alice"'s page
      And I have turned off jQuery effects
      And I click "Mention" button
      And I expand the publisher in the modal window
      And I append "I am eating a yogurt" to the publisher
      And I press the aspect dropdown in the modal window
      And I toggle the aspect "DidntPostTo" in the modal window
      And I press "Share" in the modal window

      When I am on the aspects page
      And I follow "PostTo" within "#aspect_nav"
      Then I should see "I am eating a yogurt"

      When I am on the aspects page
      And I follow "DidntPostTo" within "#aspect_nav"
      Then I should not see "I am eating a yogurt"
