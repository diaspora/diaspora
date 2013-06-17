@javascript
Feature: editing the gettig started in the mobile view

  Scenario: editing gettig started fields
    When I go to the new user registration page
    And I fill in the following:
        | user_username              |     amparito          |
        | user_email                 |   amp@arito.com       |
        | user_password              |     secret            |
        | user_password_confirmation |     secret            |
    And I press "Continue"
    And I visit the mobile getting started page
    And I should see "Well, hello there!" and "Who are you?" and "What are you into?"
    And I should see "amparito"

    When I attach the file "spec/fixtures/bad_urls.txt" to "file" within "#file-upload"
    And I preemptively confirm the alert
    And I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload"
    And I wait for the ajax to finish
    Then I should see a "img" within "#profile_photo_upload"

    When I fill in "follow_tags" with "#men"
    And I press the first ".as-result-item" within ".as-results"
    Then I should see "#men" within "ul#as-selections-tags"

    When I follow "awesome_button"
    Then I should be on the stream page
    And I should not see "awesome_button"
