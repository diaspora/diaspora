@javascript
Feature: editing your profile

  Background:
    Given I am signed in
    And I click on my name in the header
    And I follow "edit profile"
    Then I should be on my edit profile page

  Scenario: editing gender with a textbox
    When I fill in "profile_gender" with "F"
    And I press "Update Profile"
    Then I should be on my edit profile page
    And I should see "Profile updated"
    And the "profile_gender" field should contain "F"

  Scenario: editing name
    When I fill in "profile_first_name" with "Boba"
    And I fill in "profile_last_name" with "Fett"
    And I press "Update Profile"
    Then I should be on my edit profile page
    And I should see "Profile updated"
    And the "profile_first_name" field should contain "Boba"
    And the "profile_last_name" field should contain "Fett"
    
  Scenario: edit bio
    When I fill in "profile_bio" with "This is a bio"
    And I press "Update Profile"
    Then I should be on my edit profile page
    And I should see "Profile updated"
    And the "profile_bio" field should contain "This is a bio"
    
  Scenario: change birthday
    When I select "1986" from "profile_date_year"
    And I select "November" from "profile_date_month"
    And I select "30" from "profile_date_day"
    And I press "Update Profile"
    Then I should be on my edit profile page
    And I should see "Profile updated"
    And I click on my name in the header
    And I follow "view profile"  
    Then I should see "November 30 1986"