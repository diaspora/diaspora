@javascript
Feature: disconnecting users
  In order to help users feel secure on Diaspora
  As a User
  I want to be able to disconnect from others

  Background: 
    Given a user with email "bob@bob.bob"
    And a user with email "alice@alice.alice"
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page

    And I add the person to my 1st aspect

  Scenario: remove non-mutual contact from the contact show page
   When I am on "alice@alice.alice"'s page

    And I remove the person from my 1st aspect
    And I am on the home page

    Then I should have 0 contacts in "Besties"

    Then I go to the destroy user session page
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page

    Then I should not see "is sharing with you."

   Scenario Outline: remove a non-mutual contact from the last aspect on the contact show page
    When I am on "alice@alice.alice"'s page

    And I remove the person from my 1st aspect

    When I follow "My Contacts"
      Then I should have 0 contacts in "Besties"
   
    Then I go to the destroy user session page
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page

    Then I should not see "is sharing with you."

  Scenario: remove a non-mutual contact from the aspect edit page
    When I go to the home page
      And I follow "Contacts"
      And I follow "Besties"
      And I follow "Edit Besties"

      And I wait for the ajax to finish
      And I preemptively confirm the alert
      And I press the first ".added" within "#facebox .contact_list ul > li:first-child"

      And I wait for the ajax to finish
    When I follow "My Contacts"
      Then I should have 0 contacts in "Besties"

      Then I go to the destroy user session page
      When I sign in as "alice@alice.alice"
      And I am on "bob@bob.bob"'s page

      Then I should not see "is sharing with you."
