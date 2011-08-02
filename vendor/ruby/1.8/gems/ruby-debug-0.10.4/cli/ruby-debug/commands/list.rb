module Debugger
  # Implements debugger "list" command.
  class ListCommand < Command

    register_setting_get(:autolist) do
      ListCommand.always_run 
    end
    register_setting_set(:autolist) do |value|
      ListCommand.always_run = value
    end

    def regexp
      /^\s* l(?:ist)? (?:\s*([-=])|\s+(.+))? $/x
    end

    def execute
      listsize = Command.settings[:listsize]
      if !@match || !(@match[1] || @match[2])
        b = @state.previous_line ? 
        @state.previous_line + listsize : @state.line - (listsize/2)
        e = b + listsize - 1
      elsif @match[1] == '-'
        b = if @state.previous_line
              if  @state.previous_line > 0
                @state.previous_line - listsize 
              else
                @state.previous_line
              end
            else 
              @state.line - (listsize/2)
            end
        e = b + listsize - 1
      elsif @match[1] == '='
        @state.previous_line = nil
        b = @state.line - (listsize/2)
        e = b + listsize -1
      else
        b, e = @match[2].split(/[-,]/)
        if e
          b = b.to_i
          e = e.to_i
        else
          b = b.to_i - (listsize/2)
          e = b + listsize - 1
        end
      end
      @state.previous_line = display_list(b, e, @state.file, @state.line)
    end

    class << self
      def help_command
        'list'
      end

      def help(cmd)
        %{
          l[ist]\t\tlist forward
          l[ist] -\tlist backward
          l[ist] =\tlist current line
          l[ist] nn-mm\tlist given lines
          * NOTE - to turn on autolist, use 'set autolist'
        }
      end
    end

    private

    # Show FILE from line B to E where CURRENT is the current line number.
    # If we can show from B to E then we return B, otherwise we return the
    # previous line @state.previous_line.
    def display_list(b, e, file, current)
      lines = LineCache::getlines(file, 
                                  Command.settings[:reload_source_on_change])
      if lines
        b = lines.size - (e - b) if b >= lines.size
        e = lines.size if lines.size < e
        print "[%d, %d] in %s\n", b, e, file
        [b, 1].max.upto(e) do |n|
          if n > 0 && lines[n-1]
            if n == current
              print "=> %d  %s\n", n, lines[n-1].chomp
            else
              print "   %d  %s\n", n, lines[n-1].chomp
            end
          end
        end
      else
        errmsg "No sourcefile available for %s\n", file
        return @state.previous_line
      end
      return b
    end
  end
end
