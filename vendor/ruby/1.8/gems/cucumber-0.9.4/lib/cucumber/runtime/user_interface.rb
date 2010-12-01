require 'timeout'

module Cucumber
  class Runtime

    module UserInterface
      attr_writer :visitor
      
      # Output +announcement+ alongside the formatted output.
      # This is an alternative to using Kernel#puts - it will display
      # nicer, and in all outputs (in case you use several formatters)
      #
      def announce(msg)
        msg.respond_to?(:join) ? @visitor.announce(msg.join("\n")) : @visitor.announce(msg.to_s)
      end

      # Suspends execution and prompts +question+ to the console (STDOUT).
      # An operator (manual tester) can then enter a line of text and hit
      # <ENTER>. The entered text is returned, and both +question+ and
      # the result is added to the output using #announce.
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
        announce(question)

        if(Cucumber::JRUBY)
          answer = jruby_gets(timeout_seconds)
        else
          answer = mri_gets(timeout_seconds)
        end

        if(answer)
          announce(answer)
          answer
        else
          raise("Waited for input for #{timeout_seconds} seconds, then timed out.")
        end
      end

      # Embed +file+ of MIME type +mime_type+ into the output. This may or may
      # not be ignored, depending on what kind of formatter(s) are active.
      #
      def embed(file, mime_type)
        @visitor.embed(file, mime_type)
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
