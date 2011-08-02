@wire
Feature: Wire Protocol
  In order to be allow Cucumber to touch my app in intimate places
  As a developer on platform which doesn't support Ruby
  I want a low-level protocol which Cucumber can use to run steps within my app

  #
  # Cucumber's wire protocol is an implementation of Cucumber's internal
  # 'programming language' abstraction, and allows step definitions to be
  # implemented and invoked on any platform.
  #
  # Communication is over a TCP socket, which Cucumber connects to when it finds
  # a definition file with the .wire extension in the step_definitions folder
  # (or other load path).  Note that these files are rendered with ERB when loaded.
  #
  # Cucumber sends the following request messages out over the wire:
  #
  #   * step_matches   : this is used to find out whether the wire server has a
  #                      definition for a given step
  #   * invoke         : this is used to ask for a step definition to be invoked
  #   * begin_scenario : signals that cucumber is about to execute a scenario
  #   * end_scenario   : signals that cucumber has finished executing a scenario
  #   * snippet_text   : requests a snippet for an undefined step
  #
  # Every message supports two standard responses:
  #   * success        : which expects different arguments (sometimes none at
  #                      all) depending on the request.
  #   * fail           : causes a Cucumber::WireSupport::WireException to be
  #                      raised.
  #
  # Some messages support more responses - see below for details.
  #
  # A WirePacket flowing in either direction is formatted as a JSON-encoded
  # string, with a newline character signaling the end of a packet. See the
  # specs for Cucumber::WireSupport::WirePacket for more details.
  #
  # These messages are described in detail below, with examples.
  #

  Background:
    Given a standard Cucumber project directory structure
    And a file named "features/wired.feature" with:
      """
      Feature: High strung
        Scenario: Wired
          Given we're all wired

      """
    And a file named "features/step_definitions/some_remote_place.wire" with:
      """
      host: localhost
      port: 54321

      """


  #
  # # Request: 'step_matches'
  #
  # When the features have been parsed, Cucumber will send a step_matches
  # message to ask the wire server if it can match a step name. This happens for
  # each of the steps in each of the features.
  #
  # The wire server replies with an array of StepMatch objects.

  Scenario: Dry run finds no step match
    Given there is a wire server running on port 54321 which understands the following protocol:
      | request                                              | response       |
      | ["step_matches",{"name_to_match":"we're all wired"}] | ["success",[]] |
    When I run cucumber --dry-run --no-snippets -f progress
    And it should pass with
      """
      U

      1 scenario (1 undefined)
      1 step (1 undefined)

      """

  # When each StepMatch is returned, it contains the following data:
  #   * id   - identifier for the step definition to be used later when if it
  #            needs to be invoked. The identifier can be any string value and
  #            is simply used for the wire server's own reference.
  #   * args - any argument values as captured by the wire end's own regular
  #            expression (or other argument matching) process.
  Scenario: Dry run finds a step match
    Given there is a wire server running on port 54321 which understands the following protocol:
      | request                                              | response                            |
      | ["step_matches",{"name_to_match":"we're all wired"}] | ["success",[{"id":"1", "args":[]}]] |
    When I run cucumber --dry-run -f progress
    And it should pass with
      """
      -

      1 scenario (1 skipped)
      1 step (1 skipped)

      """

  # Optionally, the StepMatch can also contain a source reference, and a native
  # regexp string which will be used by some formatters.
  Scenario: Step matches returns details about the remote step definition
    Given there is a wire server running on port 54321 which understands the following protocol:
      | request                                              | response                                                                           |
      | ["step_matches",{"name_to_match":"we're all wired"}] | ["success",[{"id":"1", "args":[], "source":"MyApp.MyClass:123", "regexp":"we.*"}]] |
    When I run cucumber -f stepdefs --dry-run
    Then STDERR should be empty
    And it should pass with
      """
      -

      we.*   # MyApp.MyClass:123

      1 scenario (1 skipped)
      1 step (1 skipped)

      """


  #
  # # Request: 'invoke'
  #
  # Assuming a StepMatch was returned for a given step name, when it's time to
  # invoke that step definition, Cucumber will send an invoke message.
  #
  # The invoke message contains the ID of the step definition, as returned by
  # the wire server in response to the the step_matches call, along with the
  # arguments that were parsed from the step name during the same step_matches
  # call.
  #
  # The wire server will normally[1] reply one of the following:
  #   * success
  #   * fail
  #   * pending : optionally takes a message argument
  #
  # [1] This isn't the whole story: see also wire_protocol_table_diffing.feature
  #

  # ## Pending Steps
  #
  Scenario: Invoke a step definition which is pending
    Given there is a wire server running on port 54321 which understands the following protocol:
      | request                                              | response                            |
      | ["step_matches",{"name_to_match":"we're all wired"}] | ["success",[{"id":"1", "args":[]}]] |
      | ["begin_scenario"]                                   | ["success"]                         |
      | ["invoke",{"id":"1","args":[]}]                      | ["pending", "I'll do it later"]     |
      | ["end_scenario"]                                     | ["success"]                         |
    When I run cucumber -f pretty -q
    And it should pass with
      """
      Feature: High strung

        Scenario: Wired
          Given we're all wired
            I'll do it later (Cucumber::Pending)
            features/wired.feature:3:in `Given we're all wired'

      1 scenario (1 pending)
      1 step (1 pending)

      """

  # ## Passing Steps
  #
  Scenario: Invoke a step definition which passes
    Given there is a wire server running on port 54321 which understands the following protocol:
      | request                                              | response                            |
      | ["step_matches",{"name_to_match":"we're all wired"}] | ["success",[{"id":"1", "args":[]}]] |
      | ["begin_scenario"]                                   | ["success"]                         |
      | ["invoke",{"id":"1","args":[]}]                      | ["success"]                         |
      | ["end_scenario"]                                     | ["success"]                         |
    When I run cucumber -f progress
    And it should pass with
      """
      .

      1 scenario (1 passed)
      1 step (1 passed)

      """

  # ## Failing Steps
  #
  # When an invoked step definition fails, it can return details of the exception
  # in the reply to invoke. This causes a Cucumber::WireSupport::WireException to be
  # raised.
  #
  # Valid arguments are:
  #   * message (mandatory)
  #   * exception
  #   * backtrace
  #
  # See the specs for Cucumber::WireSupport::WireException for more details
  #
  Scenario: Invoke a step definition which fails
    Given there is a wire server running on port 54321 which understands the following protocol:
      | request                                              | response                                                                            |
      | ["step_matches",{"name_to_match":"we're all wired"}] | ["success",[{"id":"1", "args":[]}]]                                                 |
      | ["begin_scenario"]                                   | ["success"]                                                                         |
      | ["invoke",{"id":"1","args":[]}]                      | ["fail",{"message":"The wires are down", "exception":"Some.Foreign.ExceptionType"}] |
      | ["end_scenario"]                                     | ["success"]                                                                         |
    When I run cucumber -f progress
    Then STDERR should be empty
    And it should fail with
      """
      F

      (::) failed steps (::)

      The wires are down (Some.Foreign.ExceptionType from localhost:54321)
      features/wired.feature:3:in `Given we're all wired'

      Failing Scenarios:
      cucumber features/wired.feature:2 # Scenario: Wired

      1 scenario (1 failed)
      1 step (1 failed)

      """

  # ## Step Arguments
  #
  # Imagine we have a step definition like:
  #
  #     Given /we're all (.*)/ do | what_we_are |
  #     end
  #
  # When this step definition matches the step name in our feature, the word
  # 'wired' will be captured as an argument.
  #
  # Cucumber expects this StepArgument to be returned in the StepMatch. The keys
  # have the following meanings:
  #   * val : the value of the string captured for that argument from the step
  #           name passed in step_matches
  #   * pos : the position within the step name that the argument was matched
  #           (used for formatter highlighting)
  #
  Scenario: Invoke a step definition which takes string arguments (and passes)
    Given there is a wire server running on port 54321 which understands the following protocol:
      | request                                              | response                                                     |
      | ["step_matches",{"name_to_match":"we're all wired"}] | ["success",[{"id":"1", "args":[{"val":"wired", "pos":10}]}]] |
      | ["begin_scenario"]                                   | ["success"]                                                  |
      | ["invoke",{"id":"1","args":["wired"]}]               | ["success"]                                                  |
      | ["end_scenario"]                                     | ["success"]                                                  |
    When I run cucumber -f progress
    Then STDERR should be empty
    And it should pass with
      """
      .

      1 scenario (1 passed)
      1 step (1 passed)

      """

  # ## Multiline Table Arguments
  #
  # When the step has a multiline table argument, it will be passed with the
  # invoke message as a string - a serialized JSON array of array of strings.
  # In the following scenario our step definition takes two arguments - one
  # captures the "we're" and the other takes the table.
  Scenario: Invoke a step definition which takes table arguments (and passes)
    Given a file named "features/wired_on_tables.feature" with:
      """
      Feature: High strung
        Scenario: Wired and more
          Given we're all:
            | wired |
            | high  |
            | happy |
      """
    And there is a wire server running on port 54321 which understands the following protocol:
      | request                                                               | response                                                    |
      | ["step_matches",{"name_to_match":"we're all:"}]                       | ["success",[{"id":"1", "args":[{"val":"we're", "pos":0}]}]] |
      | ["begin_scenario"]                                                    | ["success"]                                                 |
      | ["invoke",{"id":"1","args":["we're",[["wired"],["high"],["happy"]]]}] | ["success"]                                                 |
      | ["end_scenario"]                                                      | ["success"]                                                 |
    When I run cucumber -f progress features/wired_on_tables.feature
    Then STDERR should be empty
    And it should pass with
      """
      .

      1 scenario (1 passed)
      1 step (1 passed)

      """


  #
  # # Request: 'snippets'
  #
  Scenario: Wire server returns snippets for a step that didn't match
    Given there is a wire server running on port 54321 which understands the following protocol:
      | request                                                                                          | response                         |
      | ["step_matches",{"name_to_match":"we're all wired"}]                                             | ["success",[]]                   |
      | ["snippet_text",{"step_keyword":"Given","multiline_arg_class":"","step_name":"we're all wired"}] | ["success","foo()\n  bar;\nbaz"] |
      | ["begin_scenario"]                                                                               | ["success"]                      |
      | ["end_scenario"]                                                                                 | ["success"]                      |
    When I run cucumber -f pretty
    Then STDERR should be empty
    And it should pass with
      """
      Feature: High strung

        Scenario: Wired         # features/wired.feature:2
          Given we're all wired # features/wired.feature:3

      1 scenario (1 undefined)
      1 step (1 undefined)

      You can implement step definitions for undefined steps with these snippets:

      foo()
        bar;
      baz


      """

  #
  # # Bad Response
  #
  Scenario: Unexpected response
    Given there is a wire server running on port 54321 which understands the following protocol:
      | request            | response  |
      | ["begin_scenario"] | ["yikes"] |
    When I run cucumber -f progress
    Then STDERR should match
      """
      undefined method `handle_yikes'
      """
