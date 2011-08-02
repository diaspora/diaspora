require 'rspec/core/extensions'
require 'rspec/core/load_path'
require 'rspec/core/deprecation'
require 'rspec/core/backward_compatibility'
require 'rspec/core/reporter'

require 'rspec/core/metadata_hash_builder'
require 'rspec/core/hooks'
require 'rspec/core/subject'
require 'rspec/core/let'
require 'rspec/core/metadata'
require 'rspec/core/pending'

require 'rspec/core/world'
require 'rspec/core/configuration'
require 'rspec/core/command_line_configuration'
require 'rspec/core/option_parser'
require 'rspec/core/configuration_options'
require 'rspec/core/command_line'
require 'rspec/core/drb_command_line'
require 'rspec/core/runner'
require 'rspec/core/example'
require 'rspec/core/shared_context'
require 'rspec/core/shared_example_group'
require 'rspec/core/example_group'
require 'rspec/core/version'
require 'rspec/core/errors'

module RSpec
  autoload :Matchers, 'rspec/matchers'

  SharedContext = Core::SharedContext

  module Core
    def self.install_directory
      @install_directory ||= File.expand_path(File.dirname(__FILE__))
    end
  end

  def self.wants_to_quit
    world.wants_to_quit
  end

  def self.wants_to_quit=(maybe)
    world.wants_to_quit=(maybe)
  end

  def self.world
    @world ||= RSpec::Core::World.new
  end

  # Used internally to ensure examples get reloaded between multiple runs in
  # the same process.
  def self.reset
    world.reset
    configuration.reset
  end

  def self.configuration
    @configuration ||= RSpec::Core::Configuration.new
  end

  def self.configure
    warn_about_deprecated_configure if RSpec.world.example_groups.any?
    yield configuration if block_given?
  end

  def self.clear_remaining_example_groups
    world.example_groups.clear
  end

  private

    def self.warn_about_deprecated_configure
      warn <<-NOTICE

*****************************************************************
DEPRECATION WARNING: you are using deprecated behaviour that will
be removed from RSpec 3.

You have set some configuration options after an example group has
already been defined.  In RSpec 3, this will not be allowed.  All
configuration should happen before the first example group is
defined.  The configuration is happening at:

  #{caller[1]}
*****************************************************************

NOTICE
    end
end

require 'rspec/core/backward_compatibility'
require 'rspec/monkey'
