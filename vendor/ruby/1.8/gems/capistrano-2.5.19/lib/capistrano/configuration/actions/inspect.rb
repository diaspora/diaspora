require 'capistrano/errors'

module Capistrano
  class Configuration
    module Actions
      module Inspect

        # Streams the result of the command from all servers that are the
        # target of the current task. All these streams will be joined into a
        # single one, so you can, say, watch 10 log files as though they were
        # one. Do note that this is quite expensive from a bandwidth
        # perspective, so use it with care.
        #
        # The command is invoked via #invoke_command.
        #
        # Usage:
        #
        #   desc "Run a tail on multiple log files at the same time"
        #   task :tail_fcgi, :roles => :app do
        #     stream "tail -f #{shared_path}/log/fastcgi.crash.log"
        #   end
        def stream(command, options={})
          invoke_command(command, options) do |ch, stream, out|
            puts out if stream == :out
            warn "[err :: #{ch[:server]}] #{out}" if stream == :err
          end
        end

        # Executes the given command on the first server targetted by the
        # current task, collects it's stdout into a string, and returns the
        # string. The command is invoked via #invoke_command.
        def capture(command, options={})
          output = ""
          invoke_command(command, options.merge(:once => true)) do |ch, stream, data|
            case stream
            when :out then output << data
            when :err then warn "[err :: #{ch[:server]}] #{data}"
            end
          end
          output
        end

      end
    end
  end
end
