@javascript
Feature: Creating a new post
  Background:
    Given a user with username "bob"
    And I sign in as "bob@bob.bob"
    And I trumpet

  Scenario: Posting a public message with a photo
    And I write "I love RMS"
    When I select "Public" in my aspects dropdown
    And I upload a fixture picture with filename "button.gif"
    When I press "Share"
    When I go to "/stream"
    Then I should see "I love RMS" as the first post in my stream
    And "I love RMS" should be a public post in my stream
    Then "I love RMS" should have the "button.gif" picture

  Scenario: Posting to Aspects
    And I write "This is super skrunkle"
    When I select "All Aspects" in my aspects dropdown
    And I press "Share"
    When I go to "/stream"
    Then I should see "This is super skrunkle" as the first post in my stream
    Then "This is super skrunkle" should be a limited post in my stream

  Scenario: Mention a contact
   Given a user named "Alice Smith" with email "alice@alice.alice"
   And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
   And I mention "alice@alice.alice"
   And I press "Share"
   And I go to "/stream"
   Then I follow "Alice Smith"

  Scenario: Uploading multiple photos
    When I write "check out these pictures"
    And I upload a fixture picture with filename "button.gif"
    And I upload a fixture picture with filename "button.gif"
    And I press "Share"
    And I go to "/stream"
    Then "check out these pictures" should have 2 pictures
