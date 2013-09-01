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
    And I am on the home page
    Then I should see the Bitcoin address
