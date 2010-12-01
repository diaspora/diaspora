Feature: Configure any test framework to use rspec-mocks

  Test frameworks that want to use rspec-mocks can use
  RSpec::Mocks::setup(self) to hook into rspec-mocks. Doing so adds the
  following:

    To the object passed to setup:

      double # creates a test double
      mock   # creates a test double
      stub   # creates a test double

    To every object in the system:

      should_receive
      should_not_receive
      stub
      
  In order to give control to the consuming framework, none of these facilities
  are added until RSpec::Mocks::setup(self) is called. Simply requiring
  'rspec/mocks' is not sufficient. 

  NOTICE: the stub() method that is added to the object passed to setup is not
  the same stub() method that is added to every other object.

  Scenario: RSpec::Mocks::setup(object) adds double, mock, and stub methods to the submitted object
    Given a file named "foo.rb" with:
      """
      require 'rspec/mocks'

      class CodeExample
        def init
          RSpec::Mocks::setup(self)
        end
      end

      example = CodeExample.new
      example.init

      puts example.respond_to?(:double)
      puts example.respond_to?(:mock)
      puts example.respond_to?(:stub)
      """

    When I run "ruby foo.rb"
    Then the output should contain "true"
    But  the output should not contain "false"

  Scenario: RSpec::Mocks::setup(anything) adds methods to Object
    Given a file named "foo.rb" with:
      """
      require 'rspec/mocks'

      RSpec::Mocks::setup(Object.new)

      obj = Object.new

      puts obj.respond_to?(:should_receive)
      puts obj.respond_to?(:should_not_receive)
      puts obj.respond_to?(:stub)
      """

    When I run "ruby foo.rb"
    Then the output should contain "true"
    But  the output should not contain "false"

  Scenario: require "rspec/mocks" does not add methods to Object
    Given a file named "foo.rb" with:
      """
      require 'rspec/mocks'

      obj = Object.new

      puts obj.respond_to?(:should_receive)
      puts obj.respond_to?(:should_not_receive)
      puts obj.respond_to?(:stub)
      """

    When I run "ruby foo.rb"
    Then the output should contain "false"
    But  the output should not contain "true"

