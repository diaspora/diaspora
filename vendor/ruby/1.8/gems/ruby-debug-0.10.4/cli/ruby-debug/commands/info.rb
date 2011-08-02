module Debugger
  module InfoFunctions # :nodoc:
    def info_catch(*args)
      unless @state.context
        print "No frame selected.\n"
        return 
      end
      if Debugger.catchpoints and not Debugger.catchpoints.empty?
        # FIXME: show whether Exception is valid or not
        # print "Exception: is_a?(Class)\n"
        Debugger.catchpoints.each do |exception, hits|
          # print "#{exception}: #{exception.is_a?(Class)}\n"
           print "#{exception}\n"
        end
      else
        print "No exceptions set to be caught.\n"
      end
    end
  end

  # Implements debugger "info" command.
  class InfoCommand < Command
    self.allow_in_control = true
    Subcommands = 
      [
       ['args', 1, 'Argument variables of current stack frame'],
       ['breakpoints', 1, 'Status of user-settable breakpoints',
        'Without argument, list info about all breakpoints.  With an
integer argument, list info on that breakpoint.'],
       ['catch', 3, 'Exceptions that can be caught in the current stack frame'],
       ['display', 2, 'Expressions to display when program stops'],
       ['file', 4, 'Info about a particular file read in',
'
After the file name is supplied, you can list file attributes that
you wish to see.

Attributes include: "all", "basic", "breakpoint", "lines", "mtime", "path" 
and "sha1".'],
       ['files', 5, 'File names and timestamps of files read in'],
       ['global_variables', 2, 'Global variables'],
       ['instance_variables', 2, 
        'Instance variables of the current stack frame'],
       ['line', 2, 
        'Line number and file name of current position in source file'],
       ['locals', 2, 'Local variables of the current stack frame'],
       ['program', 2, 'Execution status of the program'],
       ['stack', 2, 'Backtrace of the stack'],
       ['thread', 6,  'List info about thread NUM', '
If no thread number is given, we list info for all threads. \'terse\' and \'verbose\' 
options are possible. If terse, just give summary thread name information. See 
"help info threads" for more detail about this summary information.

If \'verbose\' appended to the end of the command, then the entire
stack trace is given for each thread.'],
       ['threads', 7, 'information of currently-known threads', '
This information includes whether the thread is current (+), if it is
suspended ($), or ignored (!).  The thread number and the top stack
item. If \'verbose\' is given then the entire stack frame is shown.'],
       ['variables', 1, 
        'Local and instance variables of the current stack frame']
      ].map do |name, min, short_help, long_help| 
      SubcmdStruct.new(name, min, short_help, long_help)
    end unless defined?(Subcommands)

    InfoFileSubcommands = 
      [
       ['all', 1, 
        'All file information available - breakpoints, lines, mtime, path, and sha1'],
       ['basic', 2, 
        'basic information - path, number of lines'],
       ['breakpoints', 2, 'Show trace line numbers',
        'These are the line number where a breakpoint can be set.'],
       ['lines', 1, 'Show number of lines in the file'],
       ['mtime', 1, 'Show modification time of file'],
       ['path', 4, 'Show full file path name for file'],
       ['sha1', 1, 'Show SHA1 hash of contents of the file']
      ].map do |name, min, short_help, long_help|
      SubcmdStruct.new(name, min, short_help, long_help)
    end unless defined?(InfoFileSubcommands)

    InfoThreadSubcommands = 
      [
       ['terse', 1,   'summary information'],
       ['verbose', 1, 'summary information and stack frame info'],
      ].map do |name, min, short_help, long_help|
      SubcmdStruct.new(name, min, short_help, long_help)
    end unless defined?(InfoThreadSubcommands)

    def regexp
      /^\s* i(?:nfo)? (?:\s+(.*))?$/ix
    end
    
    def execute
      if !@match[1] || @match[1].empty?
        errmsg "\"info\" must be followed by the name of an info command:\n"
        print "List of info subcommands:\n\n"
        for subcmd in Subcommands do
          print "info #{subcmd.name} -- #{subcmd.short_help}\n"
        end
      else
        args = @match[1].split(/[ \t]+/)
        param = args.shift
        subcmd = find(Subcommands, param)
        if subcmd
          send("info_#{subcmd.name}", *args)
        else
          errmsg "Unknown info command #{param}\n"
        end
      end
    end
    
    def info_args(*args)
      unless @state.context
        print "No frame selected.\n"
        return 
      end
      locals = @state.context.frame_locals(@state.frame_pos)
      args = @state.context.frame_args(@state.frame_pos)
      args.each do |name|
        s = "#{name} = #{locals[name].inspect}"
        if s.size > self.class.settings[:width]
          s[self.class.settings[:width]-3 .. -1] = "..."
        end
        print "#{s}\n"
      end
    end
    
    def info_breakpoints(*args)
      unless @state.context
        print "info breakpoints not available here.\n"
        return 
      end
      unless Debugger.breakpoints.empty?
        brkpts = Debugger.breakpoints.sort_by{|b| b.id}
        unless args.empty?
          a = args.map{|a| a.to_i}
          brkpts = brkpts.select{|b| a.member?(b.id)}
          if brkpts.empty?
            errmsg "No breakpoints found among list given.\n"
            return
          end
        end
        print "Num Enb What\n"
        brkpts.each do |b|
          fname = Command.settings[:basename] ? 
             File.basename(b.source) : b.source
            
          if b.expr.nil?
            print "%3d %s   at %s:%s\n", 
            b.id, (b.enabled? ? 'y' : 'n'), fname, b.pos
          else
            print "%3d %s   at %s:%s if %s\n", 
            b.id, (b.enabled? ? 'y' : 'n'), fname, b.pos, b.expr
          end
          hits = b.hit_count
          if hits > 0
            s = (hits > 1) ? 's' : ''
            print "\tbreakpoint already hit #{hits} time#{s}\n"
          end
        end
      else
        print "No breakpoints.\n"
      end
    end
    
    def info_display(*args)
      unless @state.context
        print "info display not available here.\n"
        return 
      end
      if @state.display.find{|d| d[0]}
        print "Auto-display expressions now in effect:\n"
        print "Num Enb Expression\n"
        n = 1
        for d in @state.display
          print "%3d: %s  %s\n", n, (d[0] ? 'y' : 'n'), d[1] if
            d[0] != nil
          n += 1
        end
      else
        print "There are no auto-display expressions now.\n"
      end
    end
    
    def info_file(*args)
      unless args[0] 
        info_files
        return
      end
      file = args[0]
      param =  args[1]
      
      param = 'basic' unless param
      subcmd = find(InfoFileSubcommands, param)
      unless subcmd
        errmsg "Invalid parameter #{param}\n"
        return
      end
      
      unless LineCache::cached?(file)
        unless LineCache::cached_script?(file)
          print "File #{file} is not cached\n"
          return
        end
        LineCache::cache(file, Command.settings[:reload_source_on_change])
      end
      
      print "File %s", file
      path = LineCache.path(file)
      if %w(all basic path).member?(subcmd.name) and path != file
        print " - %s\n", path 
      else
        print "\n"
      end

      if %w(all basic lines).member?(subcmd.name)
        lines = LineCache.size(file)
        print "\t %d lines\n", lines if lines
      end

      if %w(all breakpoints).member?(subcmd.name)
        breakpoints = LineCache.trace_line_numbers(file)
        if breakpoints
          print "\tbreakpoint line numbers:\n" 
          print columnize(breakpoints.to_a.sort, self.class.settings[:width])
        end
      end

      if %w(all mtime).member?(subcmd.name)
        stat = LineCache.stat(file)
        print "\t%s\n", stat.mtime if stat
      end
      if %w(all sha1).member?(subcmd.name)
        print "\t%s\n", LineCache.sha1(file)
      end
    end
    
    def info_files(*args)
      files = LineCache::cached_files
      files += SCRIPT_LINES__.keys unless 'stat' == args[0] 
      files.uniq.sort.each do |file|
        stat = LineCache::stat(file)
        path = LineCache::path(file)
        print "File %s", file
        if path and path != file
          print " - %s\n", path 
        else
          print "\n"
        end
        print "\t%s\n", stat.mtime if stat
      end
    end
    
    def info_instance_variables(*args)
      unless @state.context
        print "info instance_variables not available here.\n"
        return 
      end
      obj = debug_eval('self')
      var_list(obj.instance_variables)
    end
    
    def info_line(*args)
      unless @state.context
        errmsg "info line not available here.\n"
        return 
      end
      print "Line %d of \"%s\"\n",  @state.line, @state.file
    end
    
    def info_locals(*args)
      unless @state.context
        errmsg "info line not available here.\n"
        return 
      end
      locals = @state.context.frame_locals(@state.frame_pos)
      locals.keys.sort.each do |name|
        ### FIXME: make a common routine
        begin
          s = "#{name} = #{locals[name].inspect}"
        rescue
          begin
          s = "#{name} = #{locals[name].to_s}"
          rescue
            s = "*Error in evaluation*"
          end
        end  
        if s.size > self.class.settings[:width]
          s[self.class.settings[:width]-3 .. -1] = "..."
        end
        print "#{s}\n"
      end
    end
    
    def info_program(*args)
      if not @state.context
        print "The program being debugged is not being run.\n"
        return
      elsif @state.context.dead? 
        print "The program crashed.\n"
        if Debugger.last_exception
          print("Exception: #{Debugger.last_exception.inspect}\n")
        end
        return
      end
      
      print "Program stopped. "
      case @state.context.stop_reason
      when :step
        print "It stopped after stepping, next'ing or initial start.\n"
      when :breakpoint
        print("It stopped at a breakpoint.\n")
      when :catchpoint
        print("It stopped at a catchpoint.\n")
      when :catchpoint
        print("It stopped at a catchpoint.\n")
      else
        print "unknown reason: %s\n" % @state.context.stop_reason.to_s
      end
    end
    
    def info_stack(*args)
      if not @state.context
        errmsg "info stack not available here.\n"
        return
      end
      (0...@state.context.stack_size).each do |idx|
        if idx == @state.frame_pos
          print "--> "
        else
          print "    "
        end
        print_frame(idx)
      end
    end

    def info_thread_preamble(arg)
      if not @state.context
        errmsg "info threads not available here.\n"
        return false, false
      end
      verbose = if arg
        subcmd = find(InfoThreadSubcommands, arg)
        unless subcmd
          errmsg "'terse' or 'verbose' expected. Got '#{arg}'\n"
          return false, false
        end
        'verbose' == subcmd.name
      else
        false
      end
      return true, verbose
    end
    private :info_thread_preamble
      
    def info_threads(*args)
      ok, verbose = info_thread_preamble(args[0])
      return unless ok
      threads = Debugger.contexts.sort_by{|c| c.thnum}.each do |c|
        display_context(c, !verbose)
        if verbose and not c.ignored?
          (0...c.stack_size).each do |idx|
            print "\t"
            print_frame(idx, false, c)
          end
        end
      end
    end
    
    def info_thread(*args)
      unless args[0]
        info_threads(args[0])
        return
      end
      ok, verbose = info_thread_preamble(args[1])
      return unless ok
      c = parse_thread_num("info thread" , args[0])
      return unless c
      display_context(c, !verbose)
      if verbose and not c.ignored?
        (0...c.stack_size).each do |idx|
          print "\t"
          print_frame(idx, false, c) 
        end
      end
    end
    
    def info_global_variables(*args)
      unless @state.context
        errmsg "info global_variables not available here.\n"
        return 
      end
      var_list(global_variables)
    end
    
    def info_variables(*args)
      if not @state.context
        errmsg "info variables not available here.\n"
        return
      end
      obj = debug_eval('self')
      locals = @state.context.frame_locals(@state.frame_pos)
      locals['self'] = @state.context.frame_self(@state.frame_pos)
      locals.keys.sort.each do |name|
        next if name =~ /^__dbg_/ # skip debugger pollution
        ### FIXME: make a common routine
        begin
          s = "#{name} = #{locals[name].inspect}"
        rescue
          begin
            s = "#{name} = #{locals[name].to_s}"
          rescue
            s = "#{name} = *Error in evaluation*"
          end
        end
        if s.size > self.class.settings[:width]
          s[self.class.settings[:width]-3 .. -1] = "..."
        end
        s.gsub!('%', '%%')  # protect against printf format strings
        print "#{s}\n"
      end
      var_list(obj.instance_variables, obj.instance_eval{binding()})
      var_class_self
    end
    
    class << self
      def help_command
        'info'
      end

      def help(args)
        if args[1] 
          s = args[1]
          subcmd = Subcommands.find do |try_subcmd| 
            (s.size >= try_subcmd.min) and
              (try_subcmd.name[0..s.size-1] == s)
          end
          if subcmd
            str = subcmd.short_help + '.'
            if 'file' == subcmd.name and args[2]
              s = args[2]
              subsubcmd = InfoFileSubcommands.find do |try_subcmd|
                (s.size >= try_subcmd.min) and
                  (try_subcmd.name[0..s.size-1] == s)
              end
              if subsubcmd
                str += "\n" + subsubcmd.short_help + '.'
              else
                str += "\nInvalid file attribute #{args[2]}."
              end
            else
              str += "\n" + subcmd.long_help if subcmd.long_help
            end
            return str
          else
            return "Invalid 'info' subcommand '#{args[1]}'."
          end
        end
        s = %{
          Generic command for showing things about the program being debugged.
          -- 
          List of info subcommands:
          --  
        }
        for subcmd in Subcommands do
          s += "info #{subcmd.name} -- #{subcmd.short_help}\n"
        end
        return s
      end
    end
  end
end
