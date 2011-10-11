@javascript
Feature: notes
    In order to enlighten humanity for the good of society
    As a philosopher
    I want to post my long-ass master's thesis

  Background:
      Given a user with username "bob"
      When I sign in as "bob@bob.bob"

      And I am on the notes page

  Scenario: writing a basic note
    Given I expand the publisher
    When I append "This is a note!" to the publisher
    And I press "Share"
    And I wait for the ajax to finish
    Then I should see "This is a note!"

  Scenario: writing a long note
    Given I expand the publisher
    And I append "This is a note!" to the publisher 667 times
    And I append "Why not Zoidberg?" to the publisher
    And I press "Share"
    And I wait for the ajax to finish
    Then I should see "This is a note!"
    And I should not see "Why not Zoidberg?"

    When I follow "Read More"
    Then I should see "Why not Zoidberg?"

  Scenario: seeing other's limited notes
  	Given a user with username "alice"
    And I am on "alice@alice.alice"'s page
    And I add the person to my "Besties" aspect
    When I go to the notes page
    And I append "This is a note!" to the publisher
    And I press "Share"
    And I wait for the ajax to finish

    When I sign out
    And I sign in as "alice@alice.alice"
    And I go to "bob@bob.bob"'s page
    And I add the person to my "Besties" aspect

    When I go to the notes page
    Then I should see "This is a note!"

  Scenario: seeing other's public notes
  	Given a user with username "alice"
  	And "alice@alice.alice" has a public note with text "This is a note!"
  	And I am on "alice@alice.alice"'s page
    And I add the person to my "Besties" aspect
  	When I go to the notes page
  	Then I should see "This is a note!"
