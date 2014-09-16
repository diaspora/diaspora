@javascript
Feature: posting from own profile page
    In order to be all cool and stuff
    I want to post from my profile page

    Background:
      Given I am on the home page
      And a user with username "alice"
      When I sign in as "alice@alice.alice"
      Given I have following aspects:
        | Family |
        | Work   |
      Given I am on "alice@alice.alice"'s page

    Scenario: posting some text
      Given I expand the publisher
      And I have turned off jQuery effects
      And I append "I want to understand people" to the publisher
      And I select "Family" on the aspect dropdown

      And I press "Share"

      Then I should see "I want to understand people"

      When I am on the home page
      Then I should see "I want to understand people"

      When I am on the aspects page
      And I select only "Family" aspect
      Then I should see "I want to understand people"

      When I select only "Work" aspect
      Then I should not see "I want to understand people"

    Scenario: post a photo with text
      Given I expand the publisher
      When I write the status message "who am I?"
      And I attach "spec/fixtures/button.png" to the publisher
      And I submit the publisher

      When I am on the home page
      Then I should see a "img" within ".stream_element div.photo_attachments"
      And I should see "who am I?" within ".stream_element"

    Scenario: back out of posting a photo-only post
      Given I expand the publisher
      And I have turned off jQuery effects
      And I attach "spec/fixtures/button.png" to the publisher
      And I click to delete the first uploaded photo
      Then I should not see an uploaded image within the photo drop zone
