@javascript
Feature: editing your profile
  Scenario: editing profile fields
    Given I am signed in
    And I go to the edit profile page

    When I fill in "profile_gender" with "Fearless"
    And I fill in "profile_first_name" with "Boba"
    And I fill in "profile_last_name" with "Fett"
    And I fill in "profile_bio" with "This is a bio"
    And I select "1986" from "profile_date_year"
    And I select "November" from "profile_date_month"
    And I select "30" from "profile_date_day"

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

    When I go to my new profile page
    Then I should see "Gender: Fearless"
    And I should see "Boba Fett"
    And I should see "Bio: This is a bio"
    And I should see "Birthday: 1986-11-30"
