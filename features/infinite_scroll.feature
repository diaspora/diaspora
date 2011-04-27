@javascript
Feature: infinite scroll
    In order to browse without disruption
    As medium-sized internet grazing animal
    I want the stream to infinite scroll
    
    Background:
      Given many posts from bob and alice

    Scenario: on the main stream
      When I sign in as "bob@bob.bob"
      Then I should see 15 posts

      When I scroll down
      And I wait for the ajax to finish
      #FIXME
      And I wait for the ajax to finish
      Then I should see 30 posts

      When I follow "generic"
      And I wait for the ajax to finish
      Then I should see 15 posts

      When I scroll down
      And I wait for the ajax to finish
      And I wait for the ajax to finish
      Then I should see 30 posts
