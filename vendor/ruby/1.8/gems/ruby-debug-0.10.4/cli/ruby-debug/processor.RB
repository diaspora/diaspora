require 'ruby-debug/interface'
require 'ruby-debug/command'

module Debugger

  # Should this be a mixin?
  class Processor # :nodoc
    attr_accessor :interface
    attr_reader   :processor
    attr_reader   :commands

    # Format msg with gdb-style annotation header
    def afmt(msg, newline="\n")
      "\032\032#{msg}#{newline}"
    end
    
    def aprint(msg)
      print afmt(msg) if Debugger.annotate.to_i > 2
    end

    # FIXME: use delegate? 
    def errmsg(*args)
      @interface.errmsg(*args)
    end

    # Callers of this routine should make sure to use comma to
    # separate format argments rather than %. Otherwise it seems that
    # if the string you want to print has format specifier, which
    # could happen if you are trying to show say a source-code line
    # with "puts" or "print" in it, this print routine will give an
    # error saying it is looking for more arguments.
    def print(*args)
      @interface.print(*args)
    end
    
  end

  class CommandProcessor < Processor # :nodoc:
    attr_reader   :display

    # FIXME: get from Command regexp method.
    @@Show_breakpoints_postcmd = [
                                  /^\s*b(?:reak)?/, 
                                  /^\s* cond(?:ition)? (?:\s+(\d+)\s*(.*))?$/ix,
                                  /^\s*del(?:ete)?(?:\s+(.*))?$/ix,
                                  /^\s* dis(?:able)? (?:\s+(.*))?$/ix,
                                  /^\s* en(?:able)? (?:\s+(.*))?$/ix,
                                  # "tbreak", "clear", 
                                 ]
    @@Show_annotations_run     = [
                                  /^\s*c(?:ont(?:inue)?)?(?:\s+(.*))?$/,
                                  /^\s*fin(?:ish)?$/,
                                  /^\s*n(?:ext)?([+-])?(?:\s+(.*))?$/,
                                  /^\s*s(?:tep)?([+-])?(?:\s+(.*))?$/
                                ]

    @@Show_annotations_postcmd = [
                                  /^\s* down (?:\s+(.*))? .*$/x,
                                  /^\s* f(?:rame)? (?:\s+ (.*))? \s*$/x,
                                  /^\s* u(?:p)? (?:\s+(.*))?$/x
                                 ]
    
    def initialize(interface = LocalInterface.new)
      @interface = interface
      @commands  = []
      @display   = []
      
      @mutex = Mutex.new
      @last_cmd = nil
      @last_file = nil   # Filename the last time we stopped
      @last_line = nil   # line number the last time we stopped
      @debugger_breakpoints_were_empty = false # Show breakpoints 1st time
      @debugger_displays_were_empty = true # No display 1st time
      @debugger_context_was_dead = true # Assume we haven't started.
    end
    
    def interface=(interface)
      @mutex.synchronize do
        @interface.close if @interface
        @interface = interface
      end
    end
    
    require 'pathname'  # For cleanpath
    
    # Regularize file name. 
    # This is also used as a common funnel place if basename is 
    # desired or if we are working remotely and want to change the 
    # basename. Or we are eliding filenames.
    def self.canonic_file(filename)
      # For now we want resolved filenames 
      if Command.settings[:basename]
        File.basename(filename)
      else
        # Cache this?
        Pathname.new(filename).cleanpath.to_s
      end
    end

    def self.print_location_and_text(file, line)
      file_line = "%s:%s\n%s" % [canonic_file(file), line, 
                                 Debugger.line_at(file, line)]
      # FIXME: use annotations routines
      if Debugger.annotate.to_i > 2
        file_line = "\032\032source #{file_line}"
      elsif ENV['EMACS']
        file_line = "\032\032#{file_line}"
      end
      print file_line
    end
  
    def self.protect(mname)
      alias_method "__#{mname}", mname
      module_eval %{
        def #{mname}(*args)
          @mutex.synchronize do
            return unless @interface
            __#{mname}(*args)
          end
        rescue IOError, Errno::EPIPE
          self.interface = nil
        rescue SignalException
          raise
        rescue Exception => e
          unless 
          print "INTERNAL ERROR!!! #\{$!\}\n" rescue nil
          print $!.backtrace.map{|l| "\t#\{l\}"}.join("\n") rescue nil
        end
      }
    end
    
    def at_breakpoint(context, breakpoint)
      aprint 'stopped' if Debugger.annotate.to_i > 2
      n = Debugger.breakpoints.index(breakpoint) + 1
      file = CommandProcessor.canonic_file(breakpoint.source)
      line = breakpoint.pos
      if Debugger.annotate.to_i > 2
        print afmt("source #{file}:#{line}")
      end
      print "Breakpoint %d at %s:%s\n", n, file, line
    end
    protect :at_breakpoint
    
    def at_catchpoint(context, excpt)
      aprint 'stopped' if Debugger.annotate.to_i > 2
      file = CommandProcessor.canonic_file(context.frame_file(0))
      line = context.frame_line(0)
      print afmt("%s:%d" % [file, line]) if ENV['EMACS']
      print "Catchpoint at %s:%d: `%s' (%s)\n", file, line, excpt, excpt.class
      fs = context.stack_size
      tb = caller(0)[-fs..-1]
      if tb
        for i in tb
          print "\tfrom %s\n", i
        end
      end
    end
    protect :at_catchpoint
    
    def at_tracing(context, file, line)
      return if defined?(Debugger::RDEBUG_FILE) && 
        Debugger::RDEBUG_FILE == file # Don't trace ourself
      @last_file = CommandProcessor.canonic_file(file)
      file = CommandProcessor.canonic_file(file)
      unless file == @last_file and @last_line == line and 
          Command.settings[:tracing_plus]
        print "Tracing(%d):%s:%s %s",
        context.thnum, file, line, Debugger.line_at(file, line)
        @last_file = file
        @last_line = line
      end
      always_run(context, file, line, 2)
    end
    protect :at_tracing

    def at_line(context, file, line)
      process_commands(context, file, line)
    end
    protect :at_line
    
    def at_return(context, file, line)
      context.stop_frame = -1
      process_commands(context, file, line)
    end
    
    def one_cmd(commands, context, input)
      if cmd = commands.find{ |c| c.match(input) }
        if context.dead? && cmd.class.need_context
          p cmd
          print "Command is unavailable\n"
        else
          cmd.execute
        end
      else
        unknown_cmd = commands.find{|cmd| cmd.class.unknown }
        if unknown_cmd
            unknown_cmd.execute
        else
          errmsg "Unknown command: \"#{input}\".  Try \"help\".\n"
        end
      end
    end
    
    private

    # The prompt shown before reading a command.
    def prompt(context)
      p = '(rdb:%s) ' % (context.dead?  ? 'post-mortem' : context.thnum)
      p = afmt("pre-prompt")+p+"\n"+afmt("prompt") if 
        Debugger.annotate.to_i > 2
      return p
    end

    # Run these commands, for example display commands or possibly
    # the list or irb in an "autolist" or "autoirb".
    # We return a list of commands that are acceptable to run bound
    # to the current state.
    def always_run(context, file, line, run_level)
      event_cmds = Command.commands.select{|cmd| cmd.event }

      # Remove some commands in post-mortem
      event_cmds = event_cmds.find_all do |cmd| 
        cmd.allow_in_post_mortem
      end if context.dead?

      state = State.new(self) do |s|
        s.context = context
        s.file    = file
        s.line    = line
        s.binding = context.frame_binding(0)
        s.display = display
        s.interface = interface
        s.commands = event_cmds
      end
      @interface.state = state if @interface.respond_to?('state=')
      
      # Bind commands to the current state.
      commands = event_cmds.map{|cmd| cmd.new(state)}

      commands.select do |cmd| 
        cmd.class.always_run >= run_level
      end.each {|cmd| cmd.execute}
      return state, commands
    end

    # Handle debugger commands
    def process_commands(context, file, line)
      state, @commands = always_run(context, file, line, 1)
      $rdebug_state = state if Command.settings[:debuggertesting]
      splitter = lambda do |str|
        str.split(/;/).inject([]) do |m, v|
          if m.empty?
            m << v
          else
            if m.last[-1] == ?\\
              m.last[-1,1] = ''
              m.last << ';' << v
            else
              m << v
            end
          end
          m
        end
      end
      
      preloop(@commands, context)
      CommandProcessor.print_location_and_text(file, line)
      while !state.proceed? 
        input = if @interface.command_queue.empty?
                  @interface.read_command(prompt(context))
                else
                  @interface.command_queue.shift
                end
        break unless input
        catch(:debug_error) do
          if input == ""
            next unless @last_cmd
            input = @last_cmd
          else
            @last_cmd = input
          end
          splitter[input].each do |cmd|
            one_cmd(@commands, context, cmd)
            postcmd(@commands, context, cmd)
          end
        end
      end
      postloop(@commands, context)
      exception = state.exception
      @exception = nil
      puts "raising exception #{state.exception}"
      raise exception if exception
    end # process_commands
    
    def preloop(commands, context)
      aprint('stopped') if Debugger.annotate.to_i > 2
      if context.dead?
        unless @debugger_context_was_dead
          if Debugger.annotate.to_i > 2
            aprint('exited') 
            print "The program finished.\n" 
          end
          @debugger_context_was_dead = true
        end
      end

      if Debugger.annotate.to_i > 2
        # if we are here, the stack frames have changed outside the
        # command loop (e.g. after a "continue" command), so we show
        # the annotations again
        breakpoint_annotations(commands, context)
        display_annotations(commands, context)
        annotation('stack', commands, context, "where")
        annotation('variables', commands, context, "info variables") unless
          context.dead?
      end
    end
    
    def postcmd(commands, context, cmd)
      if Debugger.annotate.to_i > 0
        cmd = @last_cmd unless cmd
        breakpoint_annotations(commands, context) if
          @@Show_breakpoints_postcmd.find{|pat| cmd =~ pat}
        display_annotations(commands, context)
        if @@Show_annotations_postcmd.find{|pat| cmd =~ pat}
          annotation('stack', commands, context, "where") if 
            context.stack_size > 0
          annotation('variables', commands, context, "info variables") unless
            context.dead?
        end
        if not context.dead? and @@Show_annotations_run.find{|pat| cmd =~ pat}
          aprint 'starting'  if Debugger.annotate.to_i > 2

          @debugger_context_was_dead = false
        end
      end
    end

    def postloop(commands, context)
    end

    def annotation(label, commands, context, cmd)
      print afmt(label)
      one_cmd(commands, context, cmd)
      ### FIXME ANNOTATE: the following line should be deleted
      print "\032\032\n"
    end

    def breakpoint_annotations(commands, context)
      unless Debugger.breakpoints.empty? and @debugger_breakpoints_were_empty
        annotation('breakpoints', commands, context, "info breakpoints") 
        @debugger_breakpoints_were_empty = Debugger.breakpoints.empty?
      end
    end

    def display_annotations(commands, context)
      return if display.empty?
#       have_display = display.find{|d| d[0]} 
#       return unless have_display and @debugger_displays_were_empty
#       @debugger_displays_were_empty = have_display
      annotation('display', commands, context, "display")
    end

    class State # :nodoc:
      attr_accessor :context, :file, :line, :binding
      attr_accessor :frame_pos, :previous_line, :display
      attr_accessor :interface, :commands, :processor
      attr_accessor :exception

      def initialize(processor=nil)
        super()
        @frame_pos     = 0
        @previous_line = nil
        @proceed       = false
        @processor     = processor
        yield self
      end

      # FIXME: use delegate? 
      def errmsg(*args)
        @interface.errmsg(*args)
      end

      def print(*args)
        @interface.print(*args)
      end

      def confirm(*args)
        @interface.confirm(*args)
      end

      def proceed?
        @proceed
      end

      def proceed
        @proceed = true
      end
    end
  end
  
  class ControlCommandProcessor < Processor # :nodoc:
    def initialize(interface)
      super()
      @interface = interface
      @debugger_context_was_dead = true # Assume we haven't started.
    end
    
    def process_commands(verbose=false)
      control_cmds = Command.commands.select do |cmd| 
        cmd.allow_in_control 
      end
      state = State.new(@interface, control_cmds)
      @commands = control_cmds.map{|cmd| cmd.new(state) }

      unless @debugger_context_was_dead
        if Debugger.annotate.to_i > 2
          aprint 'exited'  
          print "The program finished.\n" 
        end
        @debugger_context_was_dead = true
      end

      while input = @interface.read_command(prompt(nil))
        print "+#{input}" if verbose
        catch(:debug_error) do
          if cmd = @commands.find{|c| c.match(input) }
            cmd.execute
          else
            errmsg "Unknown command\n"
          end
        end
      end
    rescue IOError, Errno::EPIPE
    rescue Exception
      print "INTERNAL ERROR!!! #{$!}\n" rescue nil
      print $!.backtrace.map{|l| "\t#{l}"}.join("\n") rescue nil
    ensure
      @interface.close
    end

    # The prompt shown before reading a command.
    # Note: have an unused 'context' parameter to match the local interface.
    def prompt(context)
      p = '(rdb:ctrl) '
      p = afmt("pre-prompt")+p+"\n"+afmt("prompt") if 
        Debugger.annotate.to_i > 2
      return p
    end

    class State # :nodoc:
      attr_reader :commands, :interface
      
      def initialize(interface, commands)
        @interface = interface
        @commands = commands
      end
      
      def proceed
      end
      
      def errmsg(*args)
        @interface.print(*args)
      end
      
      def print(*args)
        @interface.print(*args)
      end
      
      def confirm(*args)
        'y'
      end
      
      def context
        nil
      end

      def file
        errmsg "No filename given.\n"
        throw :debug_error
      end
    end # State
  end
end
