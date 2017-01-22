@javascript
Feature: donations
  In order to accept donation
  As a podmin
  I want a donation box shown on the stream page

  Background:
    Given following user exists:
      | username | email             |
      | Alice    | alice@alice.alice |
    And I sign in as "alice@alice.alice"

  Scenario: Bitcoin donations
    Given I have configured a Bitcoin address
    And I go to the home page
    Then I should see "Donate" within ".info-bar"
    And I click on "Donate" navbar title
    Then I should see the Bitcoin address

  Scenario: Liberapay donations
    Given I have configured a Liberapay username
    And I go to the home page
    Then I should see "Donate" within ".info-bar"
    And I click on "Donate" navbar title
    Then I should see the Liberapay donate button
