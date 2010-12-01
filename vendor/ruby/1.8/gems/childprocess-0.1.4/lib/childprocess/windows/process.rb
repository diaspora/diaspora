module ChildProcess
  module Windows
    class Process < AbstractProcess

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
        }

        if @io
          opts[:stdout] = @io.stdout
          opts[:stderr] = @io.stderr
        end

       # TODO: escape/quote arguments properly
       command = @args.join ' '

        @pid = Lib.create_proc(command, opts)
        @handle = Handle.open(@pid)

        self
      end

    end # Process
  end # Windows
end # ChildProcess
