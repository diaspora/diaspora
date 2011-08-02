module ChildProcess
  module Windows
    class Process < AbstractProcess
      #
      # @return [Fixnum] the pid of the process after it has started
      #
      attr_reader :pid

      def io
        @io ||= Windows::IO.new
      end

      def stop(timeout = 3)
        assert_started

        # just kill right away on windows.
        log "sending KILL"
        @handle.send(WIN_SIGKILL)

        poll_for_exit(timeout)
      ensure
        @handle.close
      end

      def exited?
        return true if @exit_code
        assert_started

        code   = @handle.exit_code
        exited = code != PROCESS_STILL_ACTIVE

        log(:exited? => exited, :code => code)

        if exited
          @exit_code = code
        end

        exited
      end

      private

      def launch_process
        opts = {
          :inherit => false,
          :detach  => detach?,
          :duplex  => duplex?
        }

        if @io
          opts[:stdout] = @io.stdout
          opts[:stderr] = @io.stderr
        end

        @pid = Lib.create_proc(command_string, opts)
        @handle = Handle.open(@pid)

        if duplex?
          io._stdin = opts[:stdin]
        end

        self
      end

      def command_string
        @command_string ||= (
          @args.map { |arg| quote_if_necessary(arg.to_s) }.join ' '
        )
      end

      def quote_if_necessary(str)
        quote = str.start_with?('"') ? "'" : '"'

        case str
        when /[\s\\'"]/
          %{#{quote}#{str}#{quote}}
        else
          str
        end
      end

    end # Process
  end # Windows
end # ChildProcess
