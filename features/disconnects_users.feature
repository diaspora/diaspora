@javascript
Feature: disconnecting users
  In order to deal with life
  As a User
  I want to be able to disconnect from others

  Background: 
    Given a user with email "bob@bob.bob" 
    And a user with email "alice@alice.alice"
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
   When I sign in as "bob@bob.bob"
    And I am on the aspects manage page
   Then I should see 1 contact in "Besties"
    
    
  Scenario Outline: remove contact from the contact show page
   When I am on "alice@alice.alice"'s page
    And I follow "edit aspect membership"
    And I preemptively <accept> the alert
    And I follow "remove contact" in the modal window

    And I wait for the ajax to finish
    And I am on the aspects manage page
   Then I should see <contacts> in "Besties"

    Examples:
      | accept  | contacts    |
      | confirm | no contacts |
      | reject  | 1 contact   |

   Scenario Outline: remove last contact from the contact show page
    When I am on "alice@alice.alice"'s page
    And I follow "edit aspect membership"
    And I preemptively <accept> the alert
    And I press the first ".added" within "#facebox #aspects_list ul > li:first-child"

    And I wait for the ajax to finish
    And I am on the aspects manage page
   Then I should see <contacts> in "Besties"

    Examples:
      | accept  | contacts    |
      | confirm | no contacts |
      | reject  | 1 contact   |

  Scenario: remove contact from the aspect edit page
   When I go to the home page
    And I follow "Besties" within "#aspect_listings"

    And I wait for the ajax to finish
    And I preemptively confirm the alert
    And I press the first ".added" within "#facebox .contact_list ul > li:first-child"

    And I wait for the ajax to finish
    And I am on the aspects manage page
   Then I should see no contacts in "Besties"

  Scenario: cancel removing contact from the contact show page
   When I go to the home page
    And I follow "Besties" within "#aspect_listings"
    And I wait for the ajax to finish

    And I preemptively reject the alert
    And I press the first ".added" within "#facebox .contact_list ul > li:first-child"

    And I wait for the ajax to finish
    And I am on the aspects manage page
   Then I should see 1 contact in "Besties"

