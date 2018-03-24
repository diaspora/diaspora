@javascript
Feature: search for users and hashtags
  In order to find my friends on diaspora
  As a user
  I want search for them

Background:
  Given following users exist:
  | username       | email             |
  | Bob Jones      | bob@bob.bob       |
  | Alice Smith    | alice@alice.alice |
  | Carol Williams | carol@example.com |

Scenario: search for a user and go to its profile
  When I sign in as "bob@bob.bob"
  And I enter "Alice Sm" in the search input
  Then I should see "Alice Smith" within ".tt-menu"

  When I click on the first search result
  Then I should see "Alice Smith" within ".profile_header #name"

Scenario: search for a inexistent user and go to the search page
  When I sign in as "bob@bob.bob"
  And I enter "Trinity" in the search input
  And I press enter in the search input

  Then I should see "Users matching Trinity" within "#search_title"

Scenario: search for a user in background
  When I sign in as "bob@bob.bob"
  And I search for "user@pod.tld"
  And a person with ID "user@pod.tld" has been discovered
  Then I should see "user@pod.tld" within ".stream .info.diaspora_handle"
  And I should see a ".aspect-dropdown" within ".stream"

Scenario: search for a not searchable user
  When I sign in as "carol@example.com"
  And I go to the edit profile page
  And I mark myself as not searchable
  And I submit the form
  Then I should be on the edit profile page
  And the "profile[searchable]" checkbox should not be checked

  When I sign out
  And I sign in as "bob@bob.bob"
  And I enter "Carol Wi" in the search input
  Then I should not see any search results

  Given a user with email "bob@bob.bob" is connected with "carol@example.com"
  When I go to the home page
  And I enter "Carol Wi" in the search input
  Then I should see "Carol Williams" within ".tt-menu"

  When I click on the first search result
  Then I should see "Carol Williams" within ".profile_header #name"

Scenario: search for a tag
  When I sign in as "bob@bob.bob"
  And I enter "#Matrix" in the search input
  Then I should see "#Matrix" within ".tt-menu"

  When I click on the first search result
  Then I should be on the tag page for "matrix"
