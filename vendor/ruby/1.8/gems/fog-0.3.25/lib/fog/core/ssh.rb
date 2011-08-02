module Fog
  module SSH

    def self.new(address, username, options = {})
      unless options[:key_data] || options[:keys] || options[:password]
        raise ArgumentError.new(':key_data, :keys or :password are required to initialize SSH')
      end
      if Fog.mocking?
        Fog::SSH::Mock.new(address, username, options)
      else
        Fog::SSH::Real.new(address, username, options)
      end
    end

    def self.reset_data(keys=Mock.data.keys)
      Mock.reset_data(keys)
    end

    class Mock

      def self.data
        @data ||= Hash.new do |hash, key|
          hash[key] = {}
        end
      end

      def initialize(address, username, options)
        @address  = address
        @username = username
        @options  = options
      end

      def run(commands)
        Fog::Mock.not_implemented
      end

    end

    class Real

      def initialize(address, username, options)
        require 'net/ssh'
        @address  = address
        @username = username
        @options  = options.merge(:paranoid => false)
        @options.merge(:verbose => true)
      end

      def run(commands)
        commands = [*commands]
        results  = []
        begin
          Net::SSH.start(@address, @username, @options) do |ssh|
            commands.each do |command|
              escaped_command = command.sub(/'/, %{'"'"'})
              result = Result.new(escaped_command)
              ssh.open_channel do |ssh_channel|
                ssh_channel.request_pty
                ssh_channel.exec(%{bash -lc '#{escaped_command}'}) do |channel, success|
                  unless success
                    raise "Could not execute command: #{command.inspect}"
                  end

                  channel.on_data do |ch, data|
                    result.stdout << data
                  end

                  channel.on_extended_data do |ch, type, data|
                    next unless type == 1
                    result.stderr << data
                  end

                  channel.on_request('exit-status') do |ch, data|
                    result.status = data.read_long
                  end

                  channel.on_request('exit-signal') do |ch, data|
                    result.status = 255
                  end
                end
              end
              ssh.loop
              results << result
            end
          end
        rescue Net::SSH::HostKeyMismatch => exception
          exception.remember_host!
          sleep 0.2
          retry
        end
        results
      end

    end

    class Result

      attr_accessor :command, :stderr, :stdout, :status

      def display_stdout
        Formatador.display_line(stdout.split("\r\n"))
      end

      def display_stderr
        Formatador.display_line(stderr.split("\r\n"))
      end

      def initialize(command)
        @command = command
        @stderr = ''
        @stdout = ''
      end

    end

  end
end
