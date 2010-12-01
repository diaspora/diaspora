Feature: Calling undefined step
  
  Scenario: Call directly
    Given a step definition that calls an undefined step
    
  Scenario: Call via another
    Given call step "a step definition that calls an undefined step"