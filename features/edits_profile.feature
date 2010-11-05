@javascript
Feature: editing your profile

  Scenario: editing gender with a textbox
    Given I am signed in
    And I click on my name in the header
    And I follow "edit profile"
    Then I should be on my edit profile page
    When I fill in "person_profile_gender" with "F"
    And I press "Update Profile"
    Then I should be on my edit profile page
    And I should see "Profile updated"
    And the "person_profile_gender" field should contain "F"
