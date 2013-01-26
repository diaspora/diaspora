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

    Scenario: posting some text
      Given I am on "alice@alice.alice"'s page
      And I have turned off jQuery effects
      And I append "I want to understand people" to the publisher
      And I select "Family" on the aspect dropdown

      And I press "Share"
      And I wait for the ajax to finish

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
      When I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload"
      When I fill in the following:
          | status_message_fake_text    | who am I?    |
      
      And I press "Share"
      And I wait for the ajax to finish
      
      When I am on the home page
      Then I should see a "img" within ".stream_element div.photo_attachments"
      And I should see "who am I?" within ".stream_element"
