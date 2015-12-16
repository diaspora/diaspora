@javascript
Feature: Posting from the tag page
  In order to share my opinion on cats
  I want to post from the tag page

    Background:
      Given a user with username "alice"
      And I sign in as "alice@alice.alice"
      And I am on the tag page for "cats"

    Scenario: posting some text
      When I expand the publisher
      And I have turned off jQuery effects
      And I append "I like cats." to the publisher
      And I press "Share"
      Then "#cats I like cats." should be post 1

      When I go to the home page
      Then "#cats I like cats." should be post 1

      When I am on the tag page for "cats"
      Then "#cats I like cats." should be post 1
