@javascript
Feature: following and being followed

  Background:
    Given following users exist:
      | email             |
      | bob@bob.bob       |
      | alice@alice.alice |

    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I add the person to my "Besties" aspect
    And I sign out

  Scenario: seeing a follower's posts on their profile page, but not in your stream
    Given "bob@bob.bob" has a non public post with text "I am following you"
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    Then I should see "I am following you"

    When I go to the home page
    Then I should not see "I am following you"

  Scenario: seeing public posts of someone you follow
    Given "alice@alice.alice" has a public post with text "I am ALICE"

    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    Then I should see "I am ALICE"

    When I go to the home page
    Then I should see "I am ALICE"

  Scenario: I follow a malicious user
    When I sign in as "bob@bob.bob"
    And I go to the edit profile page
    And I fill in the following:
      | profile_first_name         | <script>alert(0)//   |
    And I press "update_profile"
    Then I should be on my edit profile page

    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    And I add the person to my "Besties" aspect
    Then I should see a flash message containing "You have started sharing with <script>alert(0)//!"

  Scenario: seeing non-public posts of someone you follow who also follows you
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    And I add the person to my "Besties" aspect
    And I add the person to my "Unicorns" aspect
    And I go to the home page
    Then I should have 1 contact in "Unicorns"
    And I should have 1 contact in "Besties"

    When I click the publisher and post "I am following you back"
    And I sign out
    And I sign in as "bob@bob.bob"
    Then I should have 1 contacts in "Besties"
    And I should see "I am following you back"

  Scenario: adding someone who follows you while creating a new aspect
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page

    And I press the first ".aspect_membership_dropdown .dropdown-toggle"
    And I press the first "a" within ".add_aspect"

    And I fill in "Name" with "Super People" in the modal window
    And I press "Create" in the modal window

    When I go to the home page
    Then I should have 1 contact in "Super People"
    Then I sign out

    When I sign in as "bob@bob.bob"
    Then I should have 1 contact in "Besties"

  Scenario: interacting with the profile page of someone you follow who is not following you
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page

    Then I should see "Besties"
    Then I should see a "#mention_button" within "#profile_buttons"
    Then I should not see a "#message_button" within "#profile_buttons"

  Scenario: interacting with the profile page of someone who follows you but who you do not follow
    Given I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page

    Then I should see "Add contact"
    Then I should not see a "#mention_button" within "#profile_buttons"
    Then I should not see a "#message_button" within "#profile_buttons"

  Scenario: interacting with the profile page of someone you follow who also follows you
    Given I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page

    When I add the person to my "Besties" aspect
    And I add the person to my "Unicorns" aspect

    When I go to "bob@bob.bob"'s page
    Then I should see "All aspects"
    Then I should see a "#mention_button" within "#profile_buttons"
    Then I should see a "#message_button" within "#profile_buttons"
