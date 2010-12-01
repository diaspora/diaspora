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

      private

      def launch_process
        pb = java.lang.ProcessBuilder.new(@args)

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
