# Visitors may create an account, but for those who are not already in the 
# system an someone must activate the account for them before it can be used.
Feature: Activating an account
  As a registered, but not yet activated, user
  I want to be able to activate my account
  So that I can log in to the site
  
  Scenario: Not-yet-activated user can activate her account
    Given a registered user named 'Reggie' # need to rewrite
  #    And  the user has activation_code: 'activate_me', activated_at: nil! 
  #    And  we try hard to remember the user's updated_at, and created_at
  #   When  she goes to /activate/activate_me
  #   Then  she should be redirected to 'login'
  #   When  she follows that redirect!
  #   Then  she should see a notice message 'Signup complete!'
  #    And  a user with login: 'reggie' should exist
  #    And  the user should have login: 'reggie', and email: 'registered@example.com'
  #    And  the user's activation_code should     be nil
  #    And  the user's activated_at    should not be nil
  #    And  she should not be logged in