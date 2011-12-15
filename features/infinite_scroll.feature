@javascript
Feature: infinite scroll
    In order to browse without disruption
    As medium-sized internet grazing animal
    I want the stream to infinite scroll
    
    Background:
      Given many posts from alice for bob
      And I resize my window to 800x600
      And I sign in as "bob@bob.bob"
      And I follow "Your Aspects"
      And I wait for the ajax to finish

    Scenario: on the main stream
      When I go to the home page
      And I wait for the ajax to finish
      Then I should see 15 posts
      And I should see "alice - 15 - #seeded"

      When I scroll down
      Then I should see 30 posts
      And I should see "alice - 30 - #seeded"

    Scenario: On a tag page
      When I go to the tag page for "seeded"
      Then I should see 15 posts
      And I should see "alice - 15 - #seeded"

      When I scroll down
      Then I should see 30 posts
      And I should see "alice - 30 - #seeded"

    Scenario: On a profile page
      And I am on "alice@alice.alice"'s page
      Then I should see 15 posts
      And I should see "alice - 15 - #seeded"

      When I scroll down
      Then I should see 30 posts
      And I should see "alice - 30 - #seeded"
