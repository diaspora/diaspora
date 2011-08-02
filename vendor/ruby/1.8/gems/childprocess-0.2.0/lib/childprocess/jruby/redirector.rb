module ChildProcess
  module JRuby
    class Redirector
      BUFFER_SIZE = 2048

      def initialize(input, output)
        @input = input
        @output = output
        @buffer = Java.byte[BUFFER_SIZE].new
      end

      def run
        read, avail = 0, 0

        while(read != -1)
          avail = [@input.available, 1].max
          read  = @input.read(@buffer, 0, avail)

          if read > 0
            @output.write(@buffer, 0, read)
          end
        end
      rescue java.io.IOException => ex
        $stderr.puts ex.message, ex.backtrace if $DEBUG
      end

    end # Redirector
  end # JRuby
end # ChildProcess
