Feature: activate 2fa

  Scenario: user activates 2fa
    Given I am signed in
    And I go to the two-factor authentication page
    When I click activate
    Then I should be on the confirmation page
    When I enter a correct token
    And I click on confirm and activate 
    Then I should be on the recovery code page
    When I click ok
    Then I should be on the two-factor authentication page
    And two-factor autentication is activated

  Scenario: user deactivates 2fa
