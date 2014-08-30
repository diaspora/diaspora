@javascript
Feature: editing the getting started in the mobile view

  Background:
    Given I toggle the mobile view
    And I am on the login page
    When I follow "Sign up"
    And I fill in the new user form
    And I submit the form
    Then I should be on the getting started page
    Then I should see the 'getting started' contents

  Scenario: new user does not add any tags in setup wizard
    When I fill in the following:
      | profile_first_name | some name     |
    And I follow "awesome_button"
    Then I should be on the stream page
    And I should not see "awesome_button"

  Scenario: new user adds a profile photo and tags
    When I attach the file "spec/fixtures/bad_urls.txt" to "file" within "#file-upload"
    And I confirm the alert
    And I attach the file "spec/fixtures/button.png" to hidden "file" within "#file-upload"
    Then I should see a "img" within "#profile_photo_upload"

    When I fill in "follow_tags" with "#men"
    And I press the first ".as-result-item" within ".as-results"
    Then I should see "#men" within "ul#as-selections-tags"

  Scenario: new user skips the setup wizard
    When I follow "awesome_button"
    Then I should be on the stream page
    And I should not see "awesome_button"
