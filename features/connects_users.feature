@javascript
Feature: sending and receiving requests

  Background: 
    Given a user with email "bob@bob.bob"
    And a user with email "alice@alice.alice"
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page

    And I press the first ".share_with.button"
    And I wait for the ajax to finish
    And I add the person to my first aspect

    And I am on the home page
    Given I expand the publisher
    When I fill in "status_message_fake_text" with "I am following you"
      And I press "Share"

    Then I go to the destroy user session page
    
  Scenario: see follower's posts on their profile page and not on the home page
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    Then I should see "I am following you"

    And I am on the home page
    Then I should not see "I am following you"

  Scenario: see following's public posts on their profile page and on the home page
    Given I sign in as "alice@alice.alice"
    And I am on the home page
    And I expand the publisher
    And I fill in "status_message_fake_text" with "I am ALICE"
    And I press the first ".public_icon" within "#publisher"
    And I press "Share"
    And I go to the destroy user session page

    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page

    Then I should see "I am ALICE"
    And I am on the home page
    Then I should see "I am ALICE"

  Scenario: mutual following the original follower should see private posts on their stream
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    And I press the 1st ".share_with.button" within "#author_info"
    And I press the 1st ".add.button" within "#facebox #aspects_list ul > li:first-child"
    And I wait for the ajax to finish
    And I press the 1st ".add.button" within "#facebox #aspects_list ul > li:nth-child(2)"
    And I wait for the ajax to finish

    When I go to the home page
    Then I go to the manage aspects page

    Then I should see 1 contact in "Unicorns"
    Then I should see 1 contact in "Besties"

    And I am on the home page
    Given I expand the publisher
    When I fill in "status_message_fake_text" with "I am following you back"
    And I press "Share"
    Then I go to the destroy user session page

    When I sign in as "bob@bob.bob"
    And I am on the manage aspects page
    Then I should see 1 contact in "Besties"

    And I am on the home page
    Then I should see "I am following you back"

  Scenario: following a contact request into a new aspect
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    And I press the first ".share_with.button" within "#author_info"
    And I fill in "Name" with "Super People" in the modal window
    And I press "aspect_submit" in the modal window
    And I wait for the ajax to finish

   When I go to the home page
   Then I go to the manage aspects page
   Then I should see 1 contact in "Super People"
   Then I go to the destroy user session page

   When I sign in as "bob@bob.bob"
   And I am on the manage aspects page
   Then I should see 1 contact in "Besties"

  Scenario: should not see start sharing and see mention if already a follower
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page

    Then I should not see "start sharing"
    Then I should see "edit aspect membership"
    Then I should see "Mention"
    Then I should not see "Message"

  Scenario: should see start sharing and not see mention if on a follower's page
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page

    Then I should see "start sharing"
    Then I should not see "edit aspect membership"
    Then I should not see "Mention"
    Then I should not see "Message"

  Scenario: should see start sharing & mention & message on mutual contacts
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    And I press the 1st ".share_with.button" within "#author_info"
    And I press the 1st ".add.button" within "#facebox #aspects_list ul > li:first-child"
    And I wait for the ajax to finish
    And I press the 1st ".add.button" within "#facebox #aspects_list ul > li:nth-child(2)"
    And I wait for the ajax to finish
    And I am on "bob@bob.bob"'s page

    Then I should not see "start sharing"
    Then I should see "edit aspect membership"
    Then I should see "Mention"
    Then I should see "Message"
