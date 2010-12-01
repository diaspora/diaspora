module Debugger

  # Implements debugger "break" command.
  class AddBreakpoint < Command
    self.allow_in_control = true
    
    def regexp
      / ^\s*
        b(?:reak)?
        (?: \s+ #{Position_regexp})? \s*
        (?: \s+ (.*))? \s*
        $
      /x
    end

    def execute
      if @match[1]
        line, _, _, expr = @match.captures
      else
        _, file, line, expr = @match.captures
      end
      if expr 
        if expr !~ /^\s*if\s+(.+)/
          if file or line
            errmsg "Expecting 'if' in breakpoint condition; got: #{expr}.\n"
          else
            errmsg "Invalid breakpoint location: #{expr}.\n"
          end
          return
        else
          expr = $1
        end
      end

      brkpt_filename = nil
      if file.nil?
        unless @state.context
          errmsg "We are not in a state that has an associated file.\n"
          return 
        end
        brkpt_filename = @state.file
        file = File.basename(@state.file)
        if line.nil? 
          # Set breakpoint at current line
          line = @state.line.to_s
        end
      elsif line !~ /^\d+$/
        # See if "line" is a method/function name
        klass = debug_silent_eval(file)
        if klass && klass.kind_of?(Module)
          class_name = klass.name if klass
        else
          errmsg "Unknown class #{file}.\n"
          throw :debug_error
        end
      else
        # FIXME: This should be done in LineCache.
        file = File.expand_path(file) if file.index(File::SEPARATOR) || \
        File::ALT_SEPARATOR && file.index(File::ALT_SEPARATOR)
        brkpt_filename = file
      end
      
      if line =~ /^\d+$/
        line = line.to_i
        if LineCache.cache(brkpt_filename, Command.settings[:reload_source_on_change])
          last_line = LineCache.size(brkpt_filename)
          if line > last_line
            errmsg("There are only %d lines in file \"%s\".\n", last_line, file) 
            return
          end
          unless LineCache.trace_line_numbers(brkpt_filename).member?(line)
            errmsg("Line %d is not a stopping point in file \"%s\".\n", line, file) 
            return
          end
        else
          errmsg("No source file named %s\n" % file)
          return unless confirm("Set breakpoint anyway? (y/n) ")
        end

        unless @state.context
          errmsg "We are not in a state we can add breakpoints.\n"
          return 
        end
        brkpt_filename = File.basename(brkpt_filename) if 
          Command.settings[:basename]
        b = Debugger.add_breakpoint brkpt_filename, line, expr
        print "Breakpoint %d file %s, line %s\n", b.id, brkpt_filename, line.to_s
        unless syntax_valid?(expr)
          errmsg("Expression \"#{expr}\" syntactically incorrect; breakpoint disabled.\n")
          b.enabled = false
        end
      else
        method = line.intern.id2name
        b = Debugger.add_breakpoint class_name, method, expr
        print "Breakpoint %d at %s::%s\n", b.id, class_name, method.to_s
      end
    end

    class << self
      def help_command
        'break'
      end

      def help(cmd)
        %{
          b[reak] file:line [if expr]
          b[reak] class(.|#)method [if expr]
          \tset breakpoint to some position, (optionally) if expr == true
        }
      end
    end
  end

  # Implements debugger "delete" command.
  class DeleteBreakpointCommand < Command
    self.allow_in_control = true

    def regexp
      /^\s *del(?:ete)? (?:\s+(.*))?$/ix
    end

    def execute
      unless @state.context
        errmsg "We are not in a state we can delete breakpoints.\n"
        return 
      end
      brkpts = @match[1]
      unless brkpts
        if confirm("Delete all breakpoints? (y or n) ")
          Debugger.breakpoints.clear
        end
      else
        brkpts.split(/[ \t]+/).each do |pos|
          pos = get_int(pos, "Delete", 1)
          return unless pos
          unless Debugger.remove_breakpoint(pos)
            errmsg "No breakpoint number %d\n", pos
          end
        end
      end
    end

    class << self
      def help_command
        'delete'
      end

      def help(cmd)
        %{
          del[ete][ nnn...]\tdelete some or all breakpoints
        }
      end
    end
  end
end
