@javascript
Feature: mentioning a contact from their profile page
    In order to enlighten humanity for the good of society
    As a rock star
    I want to mention someone more cool than the average bear

    Background:
      Given I am on the home page
      And following users exist:
        | username   |
        | bob        |
        | alice      |

      When I sign in as "bob@bob.bob"
      And a user with username "bob" is connected with "alice"
      And I have following aspects:
        | PostingTo            |
        | NotPostingThingsHere |
      And I have user with username "alice" in an aspect called "PostingTo"
      And I have user with username "alice" in an aspect called "NotPostingThingsHere"

      And I am on the home page

    Scenario: mentioning while posting to all aspects
      Given I am on "alice@alice.alice"'s page
      And I have turned off jQuery effects
      And I want to mention her from the profile
      And I append "I am eating a yogurt" to the publisher
      And I press "Share" in the modal window
      When I am on the aspects page
      And I follow "PostingTo" within "#aspects_list"
      Then I should see "I am eating a yogurt"

      When I am on the aspects page
      And I follow "NotPostingThingsHere" within "#aspects_list"
      Then I should see "I am eating a yogurt"

    Scenario: mentioning while posting to just one aspect
      Given I am on "alice@alice.alice"'s page
      And I have turned off jQuery effects
      And I want to mention her from the profile
      And I append "I am eating a yogurt" to the publisher
      And I press the aspect dropdown in the modal window
      And I toggle the aspect "NotPostingThingsHere" in the modal window
      And I press "Share" in the modal window

      When I am on the aspects page
      And I select only "PostingTo" aspect
      Then I should see "I am eating a yogurt"

      When I am on the aspects page
      And I select only "NotPostingThingsHere" aspect
      Then I should not see "I am eating a yogurt"
