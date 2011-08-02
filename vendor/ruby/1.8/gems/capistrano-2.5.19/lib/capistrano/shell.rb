require 'thread'
require 'capistrano/processable'

module Capistrano
  # The Capistrano::Shell class is the guts of the "shell" task. It implements
  # an interactive REPL interface that users can employ to execute tasks and
  # commands. It makes for a GREAT way to monitor systems, and perform quick
  # maintenance on one or more machines.
  class Shell
    include Processable

    # A Readline replacement for platforms where readline is either
    # unavailable, or has not been installed.
    class ReadlineFallback #:nodoc:
      HISTORY = []

      def self.readline(prompt)
        STDOUT.print(prompt)
        STDOUT.flush
        STDIN.gets
      end
    end

    # The configuration instance employed by this shell
    attr_reader :configuration

    # Instantiate a new shell and begin executing it immediately.
    def self.run(config)
      new(config).run!
    end

    # Instantiate a new shell
    def initialize(config)
      @configuration = config
    end

    # Start the shell running. This method will block until the shell
    # terminates.
    def run!
      setup

      puts <<-INTRO
====================================================================
Welcome to the interactive Capistrano shell! This is an experimental
feature, and is liable to change in future releases. Type 'help' for
a summary of how to use the shell.
--------------------------------------------------------------------
INTRO

      loop do
        break if !read_and_execute
      end

      @bgthread.kill
    end

    def read_and_execute
      command = read_line

      case command
        when "?", "help" then help
        when "quit", "exit" then
          puts "exiting"
          return false
        when /^set -(\w)\s*(\S+)/
          set_option($1, $2)
        when /^(?:(with|on)\s*(\S+))?\s*(\S.*)?/i
          process_command($1, $2, $3)
        else
          raise "eh?"
      end

      return true
    end

    private

      # Present the prompt and read a single line from the console. It also
      # detects ^D and returns "exit" in that case. Adds the input to the
      # history, unless the input is empty. Loops repeatedly until a non-empty
      # line is input.
      def read_line
        loop do
          command = reader.readline("cap> ")

          if command.nil?
            command = "exit"
            puts(command)
          else
            command.strip!
          end

          unless command.empty?
            reader::HISTORY << command
            return command
          end
        end
      end

      # Display a verbose help message.
      def help
        puts <<-HELP
--- HELP! ---------------------------------------------------
"Get me out of this thing. I just want to quit."
-> Easy enough. Just type "exit", or "quit". Or press ctrl-D.

"I want to execute a command on all servers."
-> Just type the command, and press enter. It will be passed,
   verbatim, to all defined servers.

"What if I only want it to execute on a subset of them?"
-> No problem, just specify the list of servers, separated by
   commas, before the command, with the `on' keyword:

   cap> on app1.foo.com,app2.foo.com echo ping

"Nice, but can I specify the servers by role?"
-> You sure can. Just use the `with' keyword, followed by the
   comma-delimited list of role names:

   cap> with app,db echo ping

"Can I execute a Capistrano task from within this shell?"
-> Yup. Just prefix the task with an exclamation mark:

   cap> !deploy
HELP
      end

      # Determine which servers the given task requires a connection to, and
      # establish connections to them if necessary. Return the list of
      # servers (names).
      def connect(task)
        servers = configuration.find_servers_for_task(task)
        needing_connections = servers - configuration.sessions.keys
        unless needing_connections.empty?
          puts "[establishing connection(s) to #{needing_connections.join(', ')}]"
          configuration.establish_connections_to(needing_connections)
        end
        servers
      end

      # Execute the given command. If the command is prefixed by an exclamation
      # mark, it is assumed to refer to another capistrano task, which will
      # be invoked. Otherwise, it is executed as a command on all associated
      # servers.
      def exec(command)
        @mutex.synchronize do
          if command[0] == ?!
            exec_tasks(command[1..-1].split)
          else
            servers = connect(configuration.current_task)
            exec_command(command, servers)
          end
        end
      ensure
        STDOUT.flush
      end

      # Given an array of task names, invoke them in sequence.
      def exec_tasks(list)
        list.each do |task_name|
          task = configuration.find_task(task_name)
          raise Capistrano::NoSuchTaskError, "no such task `#{task_name}'" unless task
          connect(task)
          configuration.execute_task(task)
        end
      rescue Capistrano::NoMatchingServersError, Capistrano::NoSuchTaskError => error
        warn "error: #{error.message}"
      end

      # Execute a command on the given list of servers.
      def exec_command(command, servers)
        command = command.gsub(/\bsudo\b/, "sudo -p '#{configuration.sudo_prompt}'")
        processor = configuration.sudo_behavior_callback(Configuration.default_io_proc)
        sessions = servers.map { |server| configuration.sessions[server] }
        options = configuration.add_default_command_options({})
        cmd = Command.new(command, sessions, options.merge(:logger => configuration.logger), &processor)
        previous = trap("INT") { cmd.stop! }
        cmd.process!
      rescue Capistrano::Error => error
        warn "error: #{error.message}"
      ensure
        trap("INT", previous)
      end

      # Return the object that will be used to query input from the console.
      # The returned object will quack (more or less) like Readline.
      def reader
        @reader ||= begin
          require 'readline'
          Readline
        rescue LoadError
          ReadlineFallback
        end
      end

      # Prepare every little thing for the shell. Starts the background
      # thread and generally gets things ready for the REPL.
      def setup
        configuration.logger.level = Capistrano::Logger::INFO

        @mutex = Mutex.new
        @bgthread = Thread.new do
          loop do
            @mutex.synchronize { process_iteration(0.1) }
          end
        end
      end

      # Set the given option to +value+.
      def set_option(opt, value)
        case opt
          when "v" then
            puts "setting log verbosity to #{value.to_i}"
            configuration.logger.level = value.to_i
          when "o" then
            case value
            when "vi" then
              puts "using vi edit mode"
              reader.vi_editing_mode
            when "emacs" then
              puts "using emacs edit mode"
              reader.emacs_editing_mode
            else
              puts "unknown -o option #{value.inspect}"
            end
          else
            puts "unknown setting #{opt.inspect}"
        end
      end

      # Process a command. Interprets the scope_type (must be nil, "with", or
      # "on") and the command. If no command is given, then the scope is made
      # effective for all subsequent commands. If the scope value is "all",
      # then the scope is unrestricted.
      def process_command(scope_type, scope_value, command)
        env_var = case scope_type
            when "with" then "ROLES"
            when "on"   then "HOSTS"
          end

        old_var, ENV[env_var] = ENV[env_var], (scope_value == "all" ? nil : scope_value) if env_var
        if command
          begin
            exec(command)
          ensure
            ENV[env_var] = old_var if env_var
          end
        else
          puts "scoping #{scope_type} #{scope_value}"
        end
      end
    end

    # All open sessions, needed to satisfy the Command::Processable include
    def sessions
      configuration.sessions.values
    end
end
