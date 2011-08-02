require 'capistrano/errors'
require 'capistrano/processable'

module Capistrano

  # This class encapsulates a single command to be executed on a set of remote
  # machines, in parallel.
  class Command
    include Processable

    class Tree
      attr_reader :configuration
      attr_reader :branches
      attr_reader :fallback

      include Enumerable

      class Branch
        attr_accessor :command, :callback
        attr_reader :options

        def initialize(command, options, callback)
          @command = command.strip.gsub(/\r?\n/, "\\\n")
          @callback = callback || Capistrano::Configuration.default_io_proc
          @options = options
          @skip = false
        end

        def last?
          options[:last]
        end

        def skip?
          @skip
        end

        def skip!
          @skip = true
        end

        def match(server)
          true
        end

        def to_s
          command.inspect
        end
      end

      class ConditionBranch < Branch
        attr_accessor :configuration
        attr_accessor :condition

        class Evaluator
          attr_reader :configuration, :condition, :server

          def initialize(config, condition, server)
            @configuration = config
            @condition = condition
            @server = server
          end

          def in?(role)
            configuration.roles[role].include?(server)
          end

          def result
            eval(condition, binding)
          end

          def method_missing(sym, *args, &block)
            if server.respond_to?(sym)
              server.send(sym, *args, &block)
            elsif configuration.respond_to?(sym)
              configuration.send(sym, *args, &block)
            else
              super
            end
          end
        end

        def initialize(configuration, condition, command, options, callback)
          @configuration = configuration
          @condition = condition
          super(command, options, callback)
        end

        def match(server)
          Evaluator.new(configuration, condition, server).result
        end

        def to_s
          "#{condition.inspect} :: #{command.inspect}"
        end
      end

      def initialize(config)
        @configuration = config
        @branches = []
        yield self if block_given?
      end

      def when(condition, command, options={}, &block)
        branches << ConditionBranch.new(configuration, condition, command, options, block)
      end

      def else(command, &block)
        @fallback = Branch.new(command, {}, block)
      end

      def branches_for(server)
        seen_last = false
        matches = branches.select do |branch|
          success = !seen_last && !branch.skip? && branch.match(server)
          seen_last = success && branch.last?
          success
        end

        matches << fallback if matches.empty? && fallback
        return matches
      end

      def each
        branches.each { |branch| yield branch }
        yield fallback if fallback
        return self
      end
    end

    attr_reader :tree, :sessions, :options

    def self.process(tree, sessions, options={})
      new(tree, sessions, options).process!
    end

    # Instantiates a new command object. The +command+ must be a string
    # containing the command to execute. +sessions+ is an array of Net::SSH
    # session instances, and +options+ must be a hash containing any of the
    # following keys:
    #
    # * +logger+: (optional), a Capistrano::Logger instance
    # * +data+: (optional), a string to be sent to the command via it's stdin
    # * +env+: (optional), a string or hash to be interpreted as environment
    #   variables that should be defined for this command invocation.
    def initialize(tree, sessions, options={}, &block)
      if String === tree
        tree = Tree.new(nil) { |t| t.else(tree, &block) }
      elsif block
        raise ArgumentError, "block given with tree argument"
      end

      @tree = tree
      @sessions = sessions
      @options = options
      @channels = open_channels
    end

    # Processes the command in parallel on all specified hosts. If the command
    # fails (non-zero return code) on any of the hosts, this will raise a
    # Capistrano::CommandError.
    def process!
      loop do
        break unless process_iteration { @channels.any? { |ch| !ch[:closed] } }
      end

      logger.trace "command finished" if logger

      if (failed = @channels.select { |ch| ch[:status] != 0 }).any?
        commands = failed.inject({}) { |map, ch| (map[ch[:command]] ||= []) << ch[:server]; map }
        message = commands.map { |command, list| "#{command.inspect} on #{list.join(',')}" }.join("; ")
        error = CommandError.new("failed: #{message}")
        error.hosts = commands.values.flatten
        raise error
      end

      self
    end

    # Force the command to stop processing, by closing all open channels
    # associated with this command.
    def stop!
      @channels.each do |ch|
        ch.close unless ch[:closed]
      end
    end

    private

      def logger
        options[:logger]
      end

      def open_channels
        sessions.map do |session|
          server = session.xserver
          tree.branches_for(server).map do |branch|
            session.open_channel do |channel|
              channel[:server] = server
              channel[:host] = server.host
              channel[:options] = options
              channel[:branch] = branch

              request_pty_if_necessary(channel) do |ch, success|
                if success
                  logger.trace "executing command", ch[:server] if logger
                  cmd = replace_placeholders(channel[:branch].command, ch)

                  if options[:shell] == false
                    shell = nil
                  else
                    shell = "#{options[:shell] || "sh"} -c"
                    cmd = cmd.gsub(/'/) { |m| "'\\''" }
                    cmd = "'#{cmd}'"
                  end

                  command_line = [environment, shell, cmd].compact.join(" ")
                  ch[:command] = command_line

                  ch.exec(command_line)
                  ch.send_data(options[:data]) if options[:data]
                else
                  # just log it, don't actually raise an exception, since the
                  # process method will see that the status is not zero and will
                  # raise an exception then.
                  logger.important "could not open channel", ch[:server] if logger
                  ch.close
                end
              end

              channel.on_data do |ch, data|
                ch[:branch].callback[ch, :out, data]
              end

              channel.on_extended_data do |ch, type, data|
                ch[:branch].callback[ch, :err, data]
              end

              channel.on_request("exit-status") do |ch, data|
                ch[:status] = data.read_long
              end

              channel.on_close do |ch|
                ch[:closed] = true
              end
            end
          end
        end.flatten
      end

      def request_pty_if_necessary(channel)
        if options[:pty]
          channel.request_pty do |ch, success|
            yield ch, success
          end
        else
          yield channel, true
        end
      end

      def replace_placeholders(command, channel)
        command.gsub(/\$CAPISTRANO:HOST\$/, channel[:host])
      end

      # prepare a space-separated sequence of variables assignments
      # intended to be prepended to a command, so the shell sets
      # the environment before running the command.
      # i.e.: options[:env] = {'PATH' => '/opt/ruby/bin:$PATH',
      #                        'TEST' => '( "quoted" )'}
      # environment returns:
      # "env TEST=(\ \"quoted\"\ ) PATH=/opt/ruby/bin:$PATH"
      def environment
        return if options[:env].nil? || options[:env].empty?
        @environment ||= if String === options[:env]
            "env #{options[:env]}"
          else
            options[:env].inject("env") do |string, (name, value)|
              value = value.to_s.gsub(/[ "]/) { |m| "\\#{m}" }
              string << " #{name}=#{value}"
            end
          end
      end
  end
end
