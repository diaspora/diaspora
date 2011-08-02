#
# Author:: Adam Jacob (<adam@opscode.com)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'chef/knife'
require 'chef/application'
require 'chef/client'
require 'chef/config'
require 'chef/log'
require 'chef/node'
require 'chef/role'
require 'chef/data_bag'
require 'chef/data_bag_item'
require 'chef/rest'
require 'chef/search/query'
require 'tmpdir'
require 'uri'

class Chef::Application::Knife < Chef::Application

  NO_COMMAND_GIVEN = "You need to pass a sub-command (e.g., knife SUB-COMMAND)\n"

  banner "Usage: #{$0} sub-command (options)"

  option :config_file, 
    :short => "-c CONFIG",
    :long  => "--config CONFIG",
    :description => "The configuration file to use"

  option :log_level, 
    :short        => "-l LEVEL",
    :long         => "--log_level LEVEL",
    :description  => "Set the log level (debug, info, warn, error, fatal)",
    :proc         => lambda { |l| l.to_sym }

  option :log_location,
    :short        => "-L LOGLOCATION",
    :long         => "--logfile LOGLOCATION",
    :description  => "Set the log file location, defaults to STDOUT",
    :proc         => nil

  option :editor,
    :short        => "-e EDITOR",
    :long         => "--editor EDITOR",
    :description  => "Set the editor to use for interactive commands",
    :default      => ENV['EDITOR']
  
  option :no_editor,
    :short        => "-n",
    :long         => "--no-editor",
    :description  => "Do not open EDITOR, just accept the data as is",
    :boolean      => true
  
  option :help,
    :short        => "-h",
    :long         => "--help",
    :description  => "Show this message",
    :on           => :tail,
    :boolean      => true
    
  option :node_name,
    :short => "-u USER",
    :long => "--user USER",
    :description => "API Client Username"

  option :client_key,
    :short => "-k KEY",
    :long => "--key KEY",
    :description => "API Client Key"

  option :chef_server_url,
    :short => "-s URL",
    :long => "--server-url URL",
    :description => "Chef Server URL"

  option :yes,
    :short => "-y",
    :long => "--yes",
    :description => "Say yes to all prompts for confirmation"

  option :defaults,
    :long => "--defaults",
    :description => "Accept default values for all questions"

  option :print_after,
    :short => "-p",
    :long => "--print-after",
    :description => "Show the data after a destructive operation"

  option :format,
    :short => "-F FORMAT",
    :long => "--format FORMAT",
    :description => "Which format to use for output",
    :default => "json"

  option :version,
    :short        => "-v",
    :long         => "--version",
    :description  => "Show chef version",
    :boolean      => true,
    :proc         => lambda {|v| puts "Chef: #{::Chef::VERSION}"},
    :exit         => 0

  # Run knife 
  def run
    Mixlib::Log::Formatter.show_time = false
    validate_and_parse_options
    Chef::Knife.run(ARGV, options)
    exit 0
  end
  
  private
  
  def validate_and_parse_options
    # Checking ARGV validity *before* parse_options because parse_options
    # mangles ARGV in some situations
    if no_command_given?
      print_help_and_exit(1, NO_COMMAND_GIVEN)
    elsif no_subcommand_given?
      if (want_help? || want_version?)
        print_help_and_exit
      else 
        print_help_and_exit(2, NO_COMMAND_GIVEN)
      end
    end
  end
  
  def no_subcommand_given?
    ARGV[0] =~ /^-/
  end
  
  def no_command_given?
    ARGV.empty?
  end

  def want_help?
    ARGV[0] =~ /^(--help|-h)$/
  end

  def want_version?
    ARGV[0] =~ /^(--version|-v)$/
  end
  
  def print_help_and_exit(exitcode=1, fatal_message=nil)
    Chef::Log.error(fatal_message) if fatal_message
  
    begin
      self.parse_options
    rescue OptionParser::InvalidOption => e
      puts "#{e}\n"
    end
    puts self.opt_parser
    puts
    Chef::Knife.list_commands
    exit exitcode
  end
  
end
