@javascript
Feature: preview posts in the stream
    In order to test markdown without posting
    As a user
    I want to see a preview of my posts in the stream

    Background:
      Given following users exist:
        | username     | email             |
        | Bob Jones    | bob@bob.bob       |
        | Alice Smith  | alice@alice.alice |
      And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
      When I sign in as "bob@bob.bob"
      Then I should not see any posts in my stream

    Scenario: preview and post a text-only message
      Given I expand the publisher
      When I write the status message "I am eating yogurt"
      And I preview the post
      Then I should see "I am eating yogurt" in the preview

      Given I edit the post
      When I write the status message "This preview rocks"
      And I preview the post
      Then I should see "This preview rocks" in the preview
      And I should not see "I am eating a yogurt" in the preview

      Given I edit the post
      When I write the status message "I like rocks"
      And I press "Share"
      Then "I like rocks" should be post 1
      When I expand the publisher
      Then I should not be in preview mode

    Scenario: preview a very long message
      Given I expand the publisher
      When I insert an extremely long status message
      And I preview the post
      Then the preview should not be collapsed
      When I press "Share"
      Then the post should be collapsed

    Scenario: preview a photo with text
      Given I expand the publisher
      And I attach "spec/fixtures/button.png" to the publisher
      When I fill in the following:
          | status_message_text    | Look at this dog    |
      And I preview the post
      Then I should see a "img" within ".md-preview .stream-element .photo-attachments"
      And I should see "Look at this dog" within ".md-preview .stream-element"
      And I close the publisher

    Scenario: preview a post with mentions
      Given I expand the publisher
      And I mention Alice in the publisher
      And I preview the post
      And I confirm the alert after I follow "Alice Smith"
      Then I should see "Alice Smith"

    Scenario: preview a post on tag page
      Given there is a user "Samuel Beckett" who's tagged "#rockstar"
      When I go to the tag page for "rockstar"
      Then I should see "Samuel Beckett"
      When I expand the publisher
      And I fill in the following:
          | status_message_text    | This preview rocks    |
      And I preview the post
      Then I should see "This preview rocks" in the preview
      And I close the publisher

    Scenario: preview a post with the poll
      Given I expand the publisher
      When I fill in the following:
          | status_message_text    | I am eating yogurt    |
      And I click on selector "#poll_creator"
      When I fill in the following:
          | status_message_text    | I am eating yogurt |
          | poll_question          | What kind of yogurt do you like? |
      And I fill in the following for the options:
          | normal |
          | not normal  |
      And I preview the post
      Then I should see a ".poll-form" within ".md-preview .stream-element"
      And I should see a "form" within ".md-preview .stream-element"
      And I close the publisher

    Scenario: preview a post with location
      Given I expand the publisher
      When I fill in the following:
          | status_message_text    | I am eating yogurt    |
      And I allow geolocation
      And I click on selector "#locator"
      When I fill in the following:
          | status_message_text    | I am eating yogurt |
          | location_address       | Some cool place |
      And I preview the post
      Then I should see a ".near-from" within ".md-preview .stream-element"
      And I should see "Some cool place" within ".md-preview .stream-element .near-from"
      And I close the publisher
