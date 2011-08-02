Feature: Background
  In for background to work properly
  As a user
  I want it to run transactionally and only once when I call an individual scenario
  
Background:
  Given plop
 
Scenario: Barping
  When I barp
 
 
Scenario: Wibbling
  When I wibble