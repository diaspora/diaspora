require 'timeout'

module Cucumber
  class Runtime

    module UserInterface
      attr_writer :visitor

      # Output +messages+ alongside the formatted output.
      # This is an alternative to using Kernel#puts - it will display
      # nicer, and in all outputs (in case you use several formatters)
      #
      def puts(*messages)
        @visitor.puts(*messages)
      end

      # Suspends execution and prompts +question+ to the console (STDOUT).
      # An operator (manual tester) can then enter a line of text and hit
      # <ENTER>. The entered text is returned, and both +question+ and
      # the result is added to the output using #puts.
      #
      # If you want a beep to happen (to grab the manual tester's attention),
      # just prepend ASCII character 7 to the question:
      #
      #   ask("#{7.chr}How many cukes are in the external system?")
      #
      # If that doesn't issue a beep, you can shell out to something else
      # that makes a sound before invoking #ask.
      #
      def ask(question, timeout_seconds)
        STDOUT.puts(question)
        STDOUT.flush
        puts(question)

        if(Cucumber::JRUBY)
          answer = jruby_gets(timeout_seconds)
        else
          answer = mri_gets(timeout_seconds)
        end

        if(answer)
          puts(answer)
          answer
        else
          raise("Waited for input for #{timeout_seconds} seconds, then timed out.")
        end
      end

      # Embed +src+ of MIME type +mime_type+ into the output. The +src+ argument may
      # be a path to a file, or if it's an image it may also be a Base64 encoded image. 
      # The embedded data may or may not be ignored, depending on what kind of formatter(s) are active.
      #
      def embed(src, mime_type, label)
        @visitor.embed(src, mime_type, label)
      end

    private
    
      def mri_gets(timeout_seconds)
        begin
          Timeout.timeout(timeout_seconds) do
            STDIN.gets
          end
        rescue Timeout::Error => e
          nil
        end
      end

      def jruby_gets(timeout_seconds)
        answer = nil
        t = java.lang.Thread.new do
          answer = STDIN.gets
        end
        t.start
        t.join(timeout_seconds * 1000)
        answer
      end
    end
    
  end
end
