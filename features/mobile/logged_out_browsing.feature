@javascript @mobile
Feature: Browsing Diaspora as a logged out user mobile
    In order to view public diaspora content
    as a random internet user
    I want to view public post and comments

    Background:
      Given a user named "Bob Jones" with email "bob@bob.bob"
      And "bob@bob.bob" has a public post with text "public stuff"
      And I sign in as "bob@bob.bob"
      And I click on selector "a.image_link.comment_action.inactive"
      And I fill in the following:
          | text            | this also    |
      And I press "Comment"
      And I log out

    Scenario: Visiting a profile page
      When I am on "bob@bob.bob"'s page
      Then I should see "public stuff" within ".ltr"
      And I click on selector "a.show_comments"
      And I should see "this also" within ".comment"
