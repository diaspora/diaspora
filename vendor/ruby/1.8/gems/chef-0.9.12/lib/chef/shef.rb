# Author:: Daniel DeLeo (<dan@kallistec.com>)
# Copyright:: Copyright (c) 2009 Daniel DeLeo
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
#

require "singleton"
require "pp"
require "etc"
require "mixlib/cli"

require 'chef/version'
require "chef/client"
require "chef/config"

require "chef/shef/shef_session"
require "chef/shef/ext"

# = Shef
# Shef is Chef in an IRB session. Shef can interact with a Chef server via the
# REST API, and run and debug recipes interactively.
module Shef
  LEADERS = Hash.new("")
  LEADERS[Chef::Recipe] = ":recipe"
  LEADERS[Chef::Node]   = ":attributes"

  class << self
    attr_accessor :client_type
    attr_accessor :options
    attr_accessor :env
    attr_writer   :editor
  end

  # Start the irb REPL with shef's customizations
  def self.start
    setup_logger
    # FUGLY HACK: irb gives us no other choice.
    irb_help = [:help, :irb_help, IRB::ExtendCommandBundle::NO_OVERRIDE]
    IRB::ExtendCommandBundle.instance_variable_get(:@ALIASES).delete(irb_help)

    parse_opts

    # HACK: this duplicates the functions of IRB.start, but we have to do it
    # to get access to the main object before irb starts.
    ::IRB.setup(nil)

    irb = IRB::Irb.new

    init(irb.context.main)


    irb_conf[:IRB_RC].call(irb.context) if irb_conf[:IRB_RC]
    irb_conf[:MAIN_CONTEXT] = irb.context

    trap("SIGINT") do
      irb.signal_handle
    end

    catch(:IRB_EXIT) do
      irb.eval_input
    end
  end

  def self.setup_logger
    Chef::Config[:log_level] ||= :warn
    Chef::Log.init(STDERR)
    Mixlib::Authentication::Log.logger = Ohai::Log.logger = Chef::Log.logger
    Chef::Log.level = Chef::Config[:log_level] || :warn
  end

  # Shef assumes it's running whenever it is defined
  def self.running?
    true
  end

  # Set the irb_conf object to something other than IRB.conf
  # usful for testing.
  def self.irb_conf=(conf_hash)
    @irb_conf = conf_hash
  end

  def self.irb_conf
    @irb_conf || IRB.conf
  end

  def self.configure_irb
    irb_conf[:HISTORY_FILE] = "~/.shef_history"
    irb_conf[:SAVE_HISTORY] = 1000

    irb_conf[:IRB_RC] = lambda do |conf|
      m = conf.main

      conf.prompt_c       = "chef#{leader(m)} > "
      conf.return_format  = " => %s \n"
      conf.prompt_i       = "chef#{leader(m)} > "
      conf.prompt_n       = "chef#{leader(m)} ?> "
      conf.prompt_s       = "chef#{leader(m)}%l> "
    end
  end

  def self.leader(main_object)
    env_string = Shef.env ? " (#{Shef.env})" : ""
    LEADERS[main_object.class] + env_string
  end

  def self.session
    unless client_type.instance.node_built?
      puts "Session type: #{client_type.session_type}"
      client_type.instance.reset!
    end
    client_type.instance
  end

  def self.init(main)
    parse_json
    configure_irb

    session # trigger ohai run + session load

    session.node.consume_attributes(@json_attribs)

    Extensions.extend_context_object(main)

    main.version
    puts

    puts "run `help' for help, `exit' or ^D to quit."
    puts
    puts "Ohai2u#{greeting}!"
  end

  def self.greeting
    " #{Etc.getlogin}@#{Shef.session.node.fqdn}"
  rescue NameError
    ""
  end

  def self.parse_json
    # HACK: copied verbatim from chef/application/client, because it's not
    # reusable as written there :(
    if Chef::Config[:json_attribs]
      begin
        json_io = open(Chef::Config[:json_attribs])
      rescue SocketError => error
        fatal!("I cannot connect to #{Chef::Config[:json_attribs]}", 2)
      rescue Errno::ENOENT => error
        fatal!("I cannot find #{Chef::Config[:json_attribs]}", 2)
      rescue Errno::EACCES => error
        fatal!("Permissions are incorrect on #{Chef::Config[:json_attribs]}. Please chmod a+r #{Chef::Config[:json_attribs]}", 2)
      rescue Exception => error
        fatal!("Got an unexpected error reading #{Chef::Config[:json_attribs]}: #{error.message}", 2)
      end

      begin
        @json_attribs = JSON.parse(json_io.read)
      rescue JSON::ParserError => error
        fatal!("Could not parse the provided JSON file (#{Chef::Config[:json_attribs]})!: " + error.message, 2)
      end
    end
  end

  def self.fatal!(message, exit_status)
    Chef::Log.fatal(message)
    exit exit_status
  end

  def self.client_type
    type = Shef::StandAloneSession
    type = Shef::SoloSession   if Chef::Config[:shef_solo]
    type = Shef::ClientSession if Chef::Config[:client]
    type = Shef::DoppelGangerSession if Chef::Config[:doppelganger]
    type
  end

  def self.parse_opts
    @options = Options.new
    @options.parse_opts
  end

  def self.editor
    @editor || Chef::Config[:editor] || ENV['EDITOR']
  end

  class Options
    include Mixlib::CLI

    def self.footer(text=nil)
      @footer = text if text
      @footer
    end

    banner("shef #{Chef::VERSION}\n\nUsage: shef [NAMED_CONF] (OPTIONS)")

    footer(<<-FOOTER)
When no CONFIG is specified, shef attempts to load a default configuration file:
* If a NAMED_CONF is given, shef will load ~/.chef/NAMED_CONF/shef.rb
* If no NAMED_CONF is given shef will load ~/.chef/shef.rb if it exists
* Shef falls back to loading /etc/chef/client.rb or /etc/chef/solo.rb if -z or
  -s options are given and no shef.rb can be found. 
FOOTER

    option :config_file,
      :short => "-c CONFIG",
      :long  => "--config CONFIG",
      :description => "The configuration file to use"

    option :help,
      :short        => "-h",
      :long         => "--help",
      :description  => "Show this message",
      :on           => :tail,
      :boolean      => true,
      :proc         => proc { print_help }

    option :log_level,
      :short  => "-l LOG_LEVEL",
      :long   => '--log-level LOG_LEVEL',
      :description => "Set the logging level",
      :proc         => proc { |level| Chef::Log.level = level.to_sym }

    option :standalone,
      :short        => "-a",
      :long         => "--standalone",
      :description  => "standalone shef session",
      :default      => true,
      :boolean      => true

    option :shef_solo,
      :short        => "-s",
      :long         => "--solo",
      :description  => "chef-solo shef session",
      :boolean      => true,
      :proc         => proc {Chef::Config[:solo] = true}

    option :client,
      :short        => "-z",
      :long         => "--client",
      :description  => "chef-client shef session",
      :boolean      => true

    option :json_attribs,
      :short => "-j JSON_ATTRIBS",
      :long => "--json-attributes JSON_ATTRIBS",
      :description => "Load attributes from a JSON file or URL",
      :proc => nil

    option :chef_server_url,
      :short => "-S CHEFSERVERURL",
      :long => "--server CHEFSERVERURL",
      :description => "The chef server URL",
      :proc => nil

    option :version,
      :short        => "-v",
      :long         => "--version",
      :description  => "Show chef version",
      :boolean      => true,
      :proc         => lambda {|v| puts "Chef: #{::Chef::VERSION}"},
      :exit         => 0

    def self.print_help
      instance = new
      instance.parse_options([])
      puts instance.opt_parser
      puts
      puts footer
      puts
      exit 1
    end

    def self.setup!
      self.new.parse_opts
    end

    def parse_opts
      remainder = parse_options
      environment = remainder.first
      # We have to nuke ARGV to make sure irb's option parser never sees it.
      # otherwise, IRB complains about command line switches it doesn't recognize.
      ARGV.clear
      config[:config_file] = config_file_for_shef_mode(environment)
      config_msg = config[:config_file] || "none (standalone shef session)"
      puts "loading configuration: #{config_msg}"
      Chef::Config.from_file(config[:config_file]) if !config[:config_file].nil? && File.exists?(config[:config_file]) && File.readable?(config[:config_file])
      Chef::Config.merge!(config)
    end

    private

    def config_file_for_shef_mode(environment)
      if config[:config_file]
        config[:config_file]
      elsif environment
        Shef.env = environment
        config_file_to_try = ::File.join(ENV['HOME'], '.chef', environment, 'shef.rb')
        unless ::File.exist?(config_file_to_try)
          puts "could not find shef config for environment #{environment} at #{config_file_to_try}"
          exit 1
        end
        config_file_to_try
      elsif ENV['HOME'] && ::File.exist?(File.join(ENV['HOME'], '.chef', 'shef.rb'))
        File.join(ENV['HOME'], '.chef', 'shef.rb')
      elsif config[:solo]
        "/etc/chef/solo.rb"
      elsif config[:client]
        "/etc/chef/client.rb"
      else
        nil
      end
    end

  end

end