@javascript
Feature: show contacts

  Background:
    Given following users exist:
      | username      | email               |
      | Bob Jones     | bob@bob.bob         |
      | Alice Smith   | alice@alice.alice   |
      | Robert Grimm  | robert@grimm.grimm  |
    And I sign in as "robert@grimm.grimm"
    And I am on "alice@alice.alice"'s page
    And I add the person to my "Unicorns" aspect

  Scenario: see own contacts on profile
    When I am on "robert@grimm.grimm"'s page
    And I press the first "a" within ".section.contact_pictures"
    Then I should see "Alice Smith"

  Scenario: see contacts of a visible aspect list 
    When I am on "bob@bob.bob"'s page
    And I add the person to my "Unicorns" aspect
    And I sign out
    And I sign in as "alice@alice.alice"
    And I am on "robert@grimm.grimm"'s page
    And I press the first "a" within ".section.contact_pictures"
    Then I should see "Bob Jones"

  Scenario: don't see contacts of an invisible aspect list 
    When I am on "bob@bob.bob"'s page
    And I add the person to my "Unicorns" aspect
    And I am on the contacts page
    And I follow "Unicorns"
    And I follow "add contacts to Unicorns"
    And I press the first "a.contact_visibility_link" in the modal window
    And I press "Done" in the modal window
    And I sign out

    And I sign in as "alice@alice.alice"
    And I am on "robert@grimm.grimm"'s page
    Then I should not see "Contacts" within "#profile_information"
