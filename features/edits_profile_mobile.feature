@javascript
Feature: editing the profile in the mobile view
  Scenario: editing profile fields
    Given I am signed in
    And I toggle the mobile view
    And I go to the edit profile page

    When I fill in the following:
      | profile_gender             | Fearless        |
      | profile_first_name         | Boba            |
      | profile_last_name          | Fett            |
      | profile_bio                | This is a bio   |
      | profile_location           | Kamino          |
    
    And I select "1986" from "profile_date_year"
    And I select "30" from "profile_date_day"
    And I select "November" from "profile_date_month"

    And I fill in "profile[tag_string]" with "#starwars"
    And I press the first ".as-result-item" within ".as-results"

    And I press "Update Profile"

    Then I should be on my edit profile page
    And I should see "Profile updated"
    And the "profile_gender" field should contain "Fearless"
    And the "profile_first_name" field should contain "Boba"
    And the "profile_last_name" field should contain "Fett"
    And I should see "This is a bio"
    And the "profile_date_year" field should be filled with "1986"
    And the "profile_date_month" field should be filled with "11"
    And the "profile_date_day" field should be filled with "30"
    And the "profile_location" field should be filled with "Kamino"
    And I should see "#starwars" within "ul#as-selections-tags"

    When I fill in "profile[tag_string]" with "#kamino"
    And I press the first ".as-result-item" within ".as-results"
   
    And I press "Update Profile"
    Then I should see "#kamino" within "ul#as-selections-tags"
    And I should see "#starwars" within "ul#as-selections-tags"
    
    When I attach the file "spec/fixtures/bad_urls.txt" to "file" within "#file-upload"
    And I preemptively confirm the alert
    And I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload"
    And I wait for the ajax to finish
    Then I should see a "img" within "#profile_photo_upload"
    
    When I go to my new profile page
    And I should see "Boba Fett"
