Feature: Native (C/Java) Lexer

  Background: 
    Given a "native" "root" parser

  Scenario: Parsing an empty feature
    Given the following text is parsed:
      """
      Feature: blah
      """
    Then there should be no parse errors

  Scenario: Parsing a comment
    Given the following text is parsed:
      """
      # A comment
      Feature: Hello
      """
    Then there should be no parse errors
