module ChildProcess
  module Unix
    class Process < AbstractProcess
      #
      # @return [Fixnum] the pid of the process after it has started
      #
      attr_reader :pid

      def io
        @io ||= Unix::IO.new
      end

      def stop(timeout = 3)
        assert_started
        send_term

        begin
          return poll_for_exit(timeout)
        rescue TimeoutError
          # try next
        end

        send_kill
        wait
      rescue Errno::ECHILD, Errno::ESRCH
        # handle race condition where process dies between timeout
        # and send_kill
        true
      end

      #
      # Did the process exit?
      #
      # @return [Boolean]
      #

      def exited?
        return true if @exit_code

        assert_started
        pid, status = ::Process.waitpid2(@pid, ::Process::WNOHANG)

        log(:pid => pid, :status => status)

        if pid
          @exit_code = status.exitstatus || status.termsig
        end

        !!pid
      end

      private

      def wait
        @exit_code = ::Process.waitpid @pid
      end

      def send_term
        send_signal 'TERM'
      end

      def send_kill
        send_signal 'KILL'
      end

      def send_signal(sig)
        assert_started

        log "sending #{sig}"
        ::Process.kill sig, @pid
      end

      def launch_process
        if @io
          stdout = @io.stdout
          stderr = @io.stderr
        end

        if duplex?
          reader, writer = ::IO.pipe
        end

        @pid = fork {
          STDOUT.reopen(stdout || "/dev/null")
          STDERR.reopen(stderr || "/dev/null")

          if duplex?
            STDIN.reopen(reader)
            writer.close
          end

          exec(*@args)
        }

        if duplex?
          io._stdin = writer
          reader.close
        end

        ::Process.detach(@pid) if detach?
      end

    end # Process
  end # Unix
end # ChildProcess
