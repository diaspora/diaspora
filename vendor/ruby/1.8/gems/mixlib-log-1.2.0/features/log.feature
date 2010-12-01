Feature: Log output
  In order to keep a record of application specific information
  As a developer
  I want to publish information through a configurable log interface

  Scenario: Log a message at the debug level
    Given a base log level of 'debug'
     When the message 'this goes out' is sent at the 'debug' level
     Then the regex '\[.+\] DEBUG: this goes out' should be logged

  Scenario: Log a message at the info level
    Given a base log level of 'info'
     When the message 'this goes out' is sent at the 'info' level
     Then the regex '\[.+\] INFO: this goes out' should be logged
     
  Scenario: Log a message at the warn level
   Given a base log level of 'warn'
    When the message 'this goes out' is sent at the 'warn' level
    Then the regex '\[.+\] WARN: this goes out' should be logged

  Scenario: Log a message at the error level
   Given a base log level of 'error'
    When the message 'this goes out' is sent at the 'error' level
    Then the regex '\[.+\] ERROR: this goes out' should be logged
    
  Scenario: Log a message at the fatal level
   Given a base log level of 'fatal'
    When the message 'this goes out' is sent at the 'fatal' level
    Then the regex '\[.+\] FATAL: this goes out' should be logged
    
  Scenario: Log messages below the current threshold should not appear
   Given a base log level of 'fatal'
    When the message 'this goes out' is sent at the 'error' level
     And the message 'this goes out' is sent at the 'warn' level
     And the message 'this goes out' is sent at the 'info' level
     And the message 'this goes out' is sent at the 'debug' level
    Then nothing should be logged
