@javascript
Feature: search for users and hashtags
  In order to find my friends on diaspora
  As a user
  I want search for them

Background:
  Given following users exist:
  | username | email |
  | Bob Jones | bob@bob.bob |
  | Alice Smith | alice@alice.alice |
  And I sign in as "bob@bob.bob"

Scenario: search for a user and go to its profile
  When I enter "Alice Sm" in the search input
  Then I should see "Alice Smith" within ".ac_results"

  When I click on the first search result
  Then I should see "Alice Smith" within ".profile_header #name"

Scenario: search for a inexistent user and go to the search page
  When I enter "Trinity" in the search input
  Then I should see "Search for Trinity" within ".ac_even"

  When I click on the first search result
  Then I should see "Users matching Trinity" within "#search_title"

Scenario: search for a tag
  When I enter "#Matrix" in the search input
  Then I should see "#matrix" within ".ac_even"

  When I click on the first search result
  Then I should be on the tag page for "matrix"
