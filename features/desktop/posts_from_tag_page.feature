@javascript
Feature: Posting from the tag page
  In order to share my opinion on cats
  I want to post from the tag page

    Background:
      Given I am on the home page
      And a user with username "alice"
      When I sign in as "alice@alice.alice"
      And I am on the tag page for "cats"

    Scenario: posting some text
      Given I expand the publisher
      And I have turned off jQuery effects
      And I append "I like cats." to the publisher
      And I press "Share"

      Then "#cats I like cats." should be post 1

      When I am on the home page
      Then "#cats I like cats." should be post 1

      When I am on the tag page for "cats"
      Then "#cats I like cats." should be post 1
