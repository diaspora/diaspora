require "utils"
require 'capistrano/cli'

class CLI_Test < Test::Unit::TestCase
  def test_options_ui_and_help_modules_should_integrate_successfully_with_configuration
    cli = Capistrano::CLI.parse(%w(-T -x -X))
    cli.expects(:puts).at_least_once
    cli.execute!
  end

  def test_options_and_execute_modules_should_integrate_successfully_with_configuration
    path = "#{File.dirname(__FILE__)}/fixtures/cli_integration.rb"
    cli = Capistrano::CLI.parse(%W(-x -X -q -f #{path} testing))
    config = cli.execute!
    assert config[:testing_occurred]
  end
end
