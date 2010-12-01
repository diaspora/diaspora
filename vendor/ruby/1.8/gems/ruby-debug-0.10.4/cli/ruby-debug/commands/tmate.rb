module Debugger
  if RUBY_PLATFORM =~ /darwin/
    class TextMateCommand < Command # :nodoc:
      def regexp
        /^\s*tm(?:ate)?(?:\s*(\d+))?$/
      end

      def execute
        if @match[1]
          frm_n = @match[1].to_i
          if frm_n > @state.context.stack_size || frm_n == 0
            print "Wrong frame number\n"
            return
          end
          file, line = @state.context.frame_file(frm_n-1), @state.context.frame_line(frm_n-1)
        else
          file, line = @state.file, @state.line
        end
        %x|open 'txmt://open?url=file://#{File.expand_path(file)}&line=#{line}'|
      end

      class << self
        def help_command
          'tmate'
        end

        def help(cmd)
          %{
            tm[ate] n\topens a current file in TextMate. 
            \t\tIt uses n-th frame if arg (n) is specifed.
          }
        end
      end
    end
  end
end
