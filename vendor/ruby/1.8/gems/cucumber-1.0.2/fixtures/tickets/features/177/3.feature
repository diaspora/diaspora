Feature: Matt's example with a comment before a step

Scenario: Upload an image for an artist and create a concert in the process
  Given I am logged in to my account
  And there is one Artist named "Pixies"
  And there is one Venue
  When I visit the page for the Artist
  And I follow "add a photo"
  And I upload an Image
  # Search on select concert page
  And I press "Search Pixies concerts" 
  And I follow "Add a new Concert"
  And I fill in new Concert information
  And I press "Preview"
  And I press "Add concert"
  # No artists appear in this photo
  And I press "Submit" 
  Then my Concert should exist with 1 Image