require "java"

module ChildProcess
  module JRuby
    class Process < AbstractProcess
      def io
        @io ||= JRuby::IO.new
      end

      def exited?
        return true if @exit_code

        assert_started
        @exit_code = @process.exitValue
        true
      rescue java.lang.IllegalThreadStateException
        false
      ensure
        log(:exit_code => @exit_code)
      end

      def stop(timeout = nil)
        assert_started

        @process.destroy
        @process.waitFor # no way to actually use the timeout here..

        @exit_code = @process.exitValue
      end

      #
      # Only supported in JRuby on a Unix operating system, thanks to limitations
      # in Java's classes
      #
      # @return [Fixnum] the pid of the process after it has started
      # @raise [NotImplementedError] when trying to access pid on non-Unix platform
      #
      def pid
        if @process.getClass.getName != "java.lang.UNIXProcess"
          raise NotImplementedError.new("pid is not supported by JRuby child processes on Windows")
        end

        # About the best way we can do this is with a nasty reflection-based impl
        # Thanks to Martijn Courteaux
        # http://stackoverflow.com/questions/2950338/how-can-i-kill-a-linux-process-in-java-with-sigkill-process-destroy-does-sigter/2951193#2951193
        field = @process.getClass.getDeclaredField("pid")
        field.accessible = true
        field.get(@process)
      end

      private

      def launch_process(&blk)
        pb = java.lang.ProcessBuilder.new(@args)
        pb.directory(java.io.File.new(Dir.pwd))
        env = pb.environment
        ENV.each { |k,v| env.put(k, v) }

        @process = pb.start

        setup_io
      end

      def setup_io
        if @io
          redirect @process.getErrorStream, @io.stderr
          redirect @process.getInputStream, @io.stdout
        else
          @process.getErrorStream.close
          @process.getInputStream.close
        end

        if duplex?
          io._stdin = @process.getOutputStream.to_io
        else
          @process.getOutputStream.close
        end
      end

      def redirect(input, output)
        if output.nil?
          input.close
          return
        end

        output = output.to_outputstream
        Thread.new { Redirector.new(input, output).run }
      end

    end # Process
  end # JRuby
end # ChildProcess
