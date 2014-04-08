@javascript
Feature: editing the getting started in the mobile view

  Scenario: editing getting started fields
    When I go to the new user registration page
    And I fill in the new user form
    And I press "Continue"
    And I visit the mobile getting started page
    Then I should see the 'getting started' contents

    When I attach the file "spec/fixtures/bad_urls.txt" to "file" within "#file-upload"
    And I confirm the alert
    And I attach the file "spec/fixtures/button.png" to hidden "file" within "#file-upload"
    Then I should see a "img" within "#profile_photo_upload"

    When I fill in "follow_tags" with "#men"
    And I press the first ".as-result-item" within ".as-results"
    Then I should see "#men" within "ul#as-selections-tags"

    When I follow "awesome_button"
    Then I should be on the stream page
    And I should not see "awesome_button"
