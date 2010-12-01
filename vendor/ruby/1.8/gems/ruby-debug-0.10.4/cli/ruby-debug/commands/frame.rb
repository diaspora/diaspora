module Debugger
  # Mix-in module to assist in command parsing.
  module FrameFunctions # :nodoc:
    def adjust_frame(frame_pos, absolute, context=@state.context)
      @state.frame_pos = 0 if context != @state.context
      if absolute
        if frame_pos < 0
          abs_frame_pos = context.stack_size + frame_pos
        else
          abs_frame_pos = frame_pos
        end
      else
        abs_frame_pos = @state.frame_pos + frame_pos
      end

      if abs_frame_pos >= context.stack_size then
        errmsg "Adjusting would put us beyond the oldest (initial) frame.\n"
        return
      elsif abs_frame_pos < 0 then
        errmsg "Adjusting would put us beyond the newest (innermost) frame.\n"
        return
      end
      if @state.frame_pos != abs_frame_pos then
        @state.previous_line = nil
        @state.frame_pos = abs_frame_pos
      end
      
      @state.file = context.frame_file(@state.frame_pos)
      @state.line = context.frame_line(@state.frame_pos)
      
      print_frame(@state.frame_pos, true)
    end
    
    def get_frame_call(prefix, pos, context)
      id = context.frame_method(pos)
      klass = context.frame_class(pos)
      call_str = ""
      if id
        args = context.frame_args(pos)
        locals = context.frame_locals(pos)
        if Command.settings[:callstyle] != :short && klass
          if Command.settings[:callstyle] == :tracked
            arg_info = context.frame_args_info(pos)
          end
          call_str << "#{klass}." 
        end
        call_str << id.id2name
        if args.any?
          call_str << "("
          args.each_with_index do |name, i|
            case Command.settings[:callstyle] 
            when :short
              call_str += "%s, " % [name]
            when :last
              klass = locals[name].class
              if klass.inspect.size > 20+3
                klass = klass.inspect[0..20]+"..." 
              end
              call_str += "%s#%s, " % [name, klass]
            when :tracked
              if arg_info && arg_info.size > i
                call_str += "#{name}: #{arg_info[i].inspect}, "
              else
                call_str += "%s, " % name
              end
            end
            if call_str.size > self.class.settings[:width] - prefix.size
              # Strip off trailing ', ' if any but add stuff for later trunc
              call_str[-2..-1] = ",...XX"
              break
            end
          end
          call_str[-2..-1] = ")" # Strip off trailing ', ' if any 
        end
      end
      return call_str
    end

    def print_frame(pos, adjust = false, context=@state.context)
      file = context.frame_file(pos)
      line = context.frame_line(pos)
      klass = context.frame_class(pos)

      unless Command.settings[:full_path]
        path_components = file.split(/[\\\/]/)
        if path_components.size > 3
          path_components[0...-3] = '...'
          file = path_components.join(File::ALT_SEPARATOR || File::SEPARATOR)
        end
      end

      frame_num = "#%d " % pos
      call_str = get_frame_call(frame_num, pos, context)
      file_line = "at line %s:%d\n" % [CommandProcessor.canonic_file(file), line]
      print frame_num
      unless call_str.empty?
        print call_str
        print ' '
        if call_str.size + frame_num.size + file_line.size > self.class.settings[:width]
          print "\n       "
        end
      end
      print file_line
      if Debugger.inside_emacs? && adjust
        fmt = (Debugger.annotate.to_i > 1 ?
               "\032\032source %s:%d\n" : "\032\032%s:%d\n")
        print fmt % [CommandProcessor.canonic_file(file), line]
      end
    end

    # Check if call stack is truncated.  This can happen if
    # Debugger.start is not called low enough in the call stack. An
    # array of additional callstack lines from caller is returned if
    # definitely truncated, false if not, and nil if we don't know.
    #
    # We determine truncation based on a passed in sentinal set via
    # caller which can be nil.  
    #
    # First we see if we can find our position in caller. If so, then
    # we compare context position to that in caller using sentinal
    # as a place to start ignoring additional caller entries. sentinal
    # is set by rdebug, but if it's not set, i.e. nil then additional
    # entries are presumably ones that we haven't recorded in context
    def truncated_callstack?(context, sentinal=nil, cs=caller)
      recorded_size = context.stack_size
      to_find_fl = "#{context.frame_file(0)}:#{context.frame_line(0)}"
      top_discard = false
      cs.each_with_index do |fl, i|
        fl.gsub!(/in `.*'$/, '')
        fl.gsub!(/:$/, '')
        if fl == to_find_fl
          top_discard = i
          break 
        end
      end
      if top_discard
        cs = cs[top_discard..-1]
        return false unless cs
        return cs unless sentinal
        if cs.size > recorded_size+2 && cs[recorded_size+2] != sentinal 
          # caller seems to truncate recursive calls and we don't.
          # See if we can find sentinal in the first 0..recorded_size+1 entries
          return false if cs[0..recorded_size+1].any?{ |f| f==sentinal }
          return cs
        end
        return false
      end
      return nil
    end


  end

  # Implements debugger "where" or "backtrace" command.
  class WhereCommand < Command
    def regexp
      /^\s*(?:w(?:here)?|bt|backtrace)$/
    end

    def execute
      (0...@state.context.stack_size).each do |idx|
        if idx == @state.frame_pos
          print "--> "
        else
          print "    "
        end
        print_frame(idx)

      end
      if truncated_callstack?(@state.context, Debugger.start_sentinal)
        print "Warning: saved frames may be incomplete;\n"
        print "compare debugger backtrace (bt) with Ruby caller(0).\n" 
      end
    end

    class << self
      def help_command
        %w|where backtrace|
      end

      def help(cmd)
        s = if cmd == 'where'
          %{
            w[here]\tdisplay stack frames
            }
            else
          %{
            bt|backtrace\t\talias for where - display stack frames
         }
            end
        s += %{
Print the entire stack frame. Each frame is numbered, the most recent
frame is 0. frame number can be referred to in the "frame" command;
"up" and "down" add or subtract respectively to frame numbers shown.
The position of the current frame is marked with -->.  } 
      end 
    end
  end

  class UpCommand < Command # :nodoc:
    def regexp
      /^\s* u(?:p)? (?:\s+(\S+))? $/x
    end

    def execute
      pos = get_int(@match[1], "Up")
      return unless pos
      adjust_frame(pos, false)
    end

    class << self
      def help_command
        'up'
      end

      def help(cmd)
        %{
          up[count]\tmove to higher frame
        }
      end
    end
  end

  class DownCommand < Command # :nodoc:
    def regexp
      /^\s* down (?:\s+(\S+))? $/x
    end

    def execute
      pos = get_int(@match[1], "Down")
      return unless pos
      adjust_frame(-pos, false)
    end

    class << self
      def help_command
        'down'
      end

      def help(cmd)
        %{
          down[count]\tmove to lower frame
        }
      end
    end
  end
  
  class FrameCommand < Command # :nodoc:
    def regexp
      / ^\s* 
        f(?:rame)? 
        (?: \s+ (\S+))? \s*
        (?: thread \s+ (.*))? \s*
        $/x
    end

    def execute
      if not @match[1]
        pos = 0
      else
        pos = get_int(@match[1], "Frame")
        return unless pos
      end
      if @match[2]
        context = parse_thread_num('frame', @match[2])
        unless context
          errmsg "Thread #{@match[2]} doesn't exist.\n"
          return
        end
      else
        context = @state.context
      end
      adjust_frame(pos, true, context)
    end

    class << self
      def help_command
        'frame'
      end

      def help(cmd)
        %{
          f[rame] [frame-number [thread thread-number]]
          Move the current frame to the specified frame number, or the
          0 if no frame-number has been given.

          A negative number indicates position from the other end.  So
          'frame -1' moves to the oldest frame, and 'frame 0' moves to
          the newest frame.

          Without an argument, the command prints the current stack
          frame. Since the current position is redisplayed, it may trigger a
          resynchronization if there is a front end also watching over
          things. 

          If a thread number is given, then we set the context for evaluating
          expressions to that frame of that thread. 
        }
      end
    end
  end
end
