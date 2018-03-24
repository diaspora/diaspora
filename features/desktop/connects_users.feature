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

  Scenario: I follow a malicious user
    When I sign in as "bob@bob.bob"
    And I go to the edit profile page
    And I fill in the following:
      | profile_first_name         | <script>alert(0)//   |
      | profile_last_name          ||
    And I press "update_profile"
    Then I should be on my edit profile page

    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    And I add the person to my "Besties" aspect
    Then I should see a flash message containing "You have started sharing with <script>alert(0)//!"

  Scenario: adding someone who follows you while creating a new aspect
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page

    And I press the first ".aspect-membership-dropdown .dropdown-toggle"
    And I press the first "a" within ".add_aspect"

    And I fill in "aspect_name" with "Super People" in the aspect creation modal
    And I click on selector ".btn-primary" in the aspect creation modal
    And I wait until ajax requests finished

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
