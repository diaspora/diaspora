@javascript
Feature: Choose birthday display

  Background:
    Given I am signed in
    And I click on my name in the header
    And I follow "Profile"
    And I follow "Edit my profile"
    Then I should be on my edit profile page
    And I select "1990" from "profile_date_year"
    And I select "July" from "profile_date_month"
    And I select "26" from "profile_date_day"

  Scenario: User just enters full birthday
    When I press "Update Profile"
    And I click on my name in the header
    And I follow "Profile"
    Then I should be on my profile page
    And I should see "birthday"
    And I should see "July"
    And I should see "26"
    And I should see "1990"

  Scenario: User leaves the year unselected
    When I select "Year" from "profile_date_year"
    And I press "Update Profile"
    And I click on my name in the header
    And I follow "Profile"
    Then I should be on my profile page
    And I should see "birthday"
    And I should see "July"
    And I should see "26"
    
  Scenario: User enters birthday and selects to display month and day only
    When select "Month and Day" from "profile_birthday_display"
    And I press "Update Profile"
    And I click on my name in the header
    And I follow "Profile"
    Then I should be on my profile page
    And I should see "birthday"
    And I should see "July"
    And I should see "26"
    And I should not see "1990"

  Scenario: User enters birthday and selects to display age only
    When select "Age only" from "profile_birthday_display"
    And I select a birthday "21" years ago
    And I press "Update Profile"
    And I click on my name in the header
    And I follow "Profile"
    Then I should be on my profile page
    And I should not see "birthday"
    And I should not see "July"
    And I should not see "26"
    And I should not see "1990"
    And I should see "age"
    And I should see the age "21"

  Scenario: User enters birthday but doesn't want to show it
    When select "Don't show" from "profile_birthday_display"
    And I press "Update Profile"
    And I click on my name in the header
    And I follow "Profile"
    Then I should be on my profile page
    And I should not see "birthday" within "#profile_information"
    And I should not see "July"
    And I should not see "26"
    And I should not see "1990"
    And I should not see "age" within "#profile_information"
    