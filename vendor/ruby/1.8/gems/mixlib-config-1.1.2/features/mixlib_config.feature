Feature: Configure an application
  In order to make it trivial to configure an application
  As a Developer
  I want to utilize a simple configuration object
  
Scenario: Set a configuration option to a string
  Given a configuration class 'ConfigIt'
  When I set 'foo' to 'bar' in configuration class 'ConfigIt'
  Then config option 'foo' is 'bar'

Scenario: Set the same configuration option to different strings for two configuration classes
  Given a configuration class 'ConfigIt'
    And a configuration class 'ConfigItToo'
  When I set 'foo' to 'bar' in configuration class 'ConfigIt'
   And I set 'foo' to 'bar2' in configuration class 'ConfigItToo'
  Then in configuration class 'ConfigItToo' config option 'foo' is 'bar2' 
   And in configuration class 'ConfigIt' config option 'foo' is 'bar'
  
Scenario: Set a configuration option to an Array
  Given a configuration class 'ConfigIt'
  When I set 'foo' to:
    |key|
    |bar|
    |baz|
  Then an array is returned for 'foo'

Scenario: Set a configuration option from a file
  Given a configuration file 'bobo.config'
   When I load the configuration
   Then config option 'foo' is 'bar'
    And config option 'baz' is 'snarl'
