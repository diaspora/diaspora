require 'ruby-debug/interface'
require 'ruby-debug/command'

# _Debugger_ is the module name space for ruby-debug.
module Debugger

  # A processor handles the kind of front-end to program interaction.
  # Debugger::Processor is the the base class with subclasses
  # Debugger::CommandProcessor and Debugger::ControlCommandProcessor.
  class Processor 
    attr_accessor :interface
    attr_reader   :processor
    attr_reader   :commands

    # Format _msg_ with gdb-style annotation header.
    def afmt(msg, newline="\n")
      "\032\032#{msg}#{newline}"
    end
    
    # Print "annotation" message _msg_. Annotation messages are used
    # by the GNU-Emacs front-end to get status about stacks and
    # the state of the debugger without having to poll it for information
    def aprint(msg)
      print afmt(msg) if Debugger.annotate.to_i > 2
    end

    # Print a debugger error message; _args_ should be compatible
    # with something you would pass to Kernel::print.
    def errmsg(*args)
      @interface.errmsg(*args)
    end

    # Print a normal debugger message; _args_ should be compatible
    # with something you would pass to Kernel::print.
    # 
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

  # A Debugger::CommandProcessor is the kind of Debugger::Processor
  # used when you are running inside the same process as the debugged
  # program.
  class CommandProcessor < Processor 
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
    
    # Regularize or "canonicalize" file name _filename_.
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
      elsif Debugger.inside_emacs?
        file_line = "\032\032#{file_line}"
      end
      print file_line
    end

    # Create a "protected" version of method _mname_. A protected
    # method handles all unhandled exceptions that would cause the
    # program to terminate.
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
        rescue Exception
          print "INTERNAL ERROR!!! #\{$!\}\n" rescue nil
          print $!.backtrace.map{|l| "\t#\{l\}"}.join("\n") rescue nil
        end
      }
    end

    # This is a callback routine when the debugged program hits a 
    # breakpoint event. For example ruby-debug-base calls this.
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
    
    # This is a callback routine when the debugged program hits a 
    # catchpoint. For example ruby-debug-base calls this.
    def at_catchpoint(context, excpt)
      aprint 'stopped' if Debugger.annotate.to_i > 2
      file = CommandProcessor.canonic_file(context.frame_file(0))
      line = context.frame_line(0)
      print afmt("%s:%d" % [file, line]) if Debugger.inside_emacs?
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

    # This is a callback routine when the debugged program hits a
    # "line" (or statement boundary) event. For example
    # ruby-debug-base calls this.
    def at_line(context, file, line)
      process_commands(context, file, line)
    end
    protect :at_line
    
    # This is a callback routine when the debugged program hits a
    # "return" event. For example ruby-debug-base calls this.
    # Note: right now ruby-debug-base does not call this. Perhaps 
    # other bases routines such as the one in JRuby do.
    def at_return(context, file, line)
      context.stop_frame = -1
      process_commands(context, file, line)
    end

    # Return the command object to run given input string _input_.
    def lookup(input)
      @commands.find{ |c| c.match(input) }
    end

    # Run a single command specified by string _input_; _commands_ is and 
    # Array of possible debugger command objects and _context_ is
    # a Debugger::Context object.
    def one_cmd(commands, context, input)
      if cmd = lookup(input)
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

    # Return a prompt string to show before reading a command.
    def prompt(context)
      p = '(rdb:%s) ' % (context.dead?  ? 'post-mortem' : context.thnum)
      p = afmt("pre-prompt")+p+"\n"+afmt("prompt") if 
        Debugger.annotate.to_i > 2
      return p
    end

    # Run commands that we always have to run before a entering a
    # command loop.  For example commands registered via debugger "set
    # display", "set autolist", or set "autoirb".  We return a list of
    # commands that are acceptable to run bound to the current state.
    def always_run(context, file, line, run_level)
      event_cmds = Command.commands.select{|cmd| cmd.event }

      # Remove some commands if we are post mortem.
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

    # This the main debugger command-line loop. Here we read a
    # debugger command, perform it, and ask for another one unless we
    # are told to continue execution or terminate.
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
    end # process_commands

    # Things we do before entering the debugger command loop.
    # Note: in the trepanning debuggers this and always_run have been
    # merged. To do this and get the order right we add a priority level
    # for each hook.
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
    
    # Things we do after leaving the debugger command loop.
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

    # Things we do after leaving the debugger command loop.
    def postloop(commands, context)
    end

    # Run a command in String _cmd_, but tag output with annotation
    # specified in String _label+. +commands_ is an Array of all
    # possible debugger command objects, and _context_ is a
    # Debugger::Context object.
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

      def initialize(processor=nil)
        super()
        @frame_pos     = 0
        @previous_line = nil
        @proceed       = false
        @processor     = processor
        yield self
      end

    # Print a debugger error message; _args_ should be compatible
    # with something you would pass to Kernel::print.
      def errmsg(*args)
        @interface.errmsg(*args)
      end

      # Print a normal debugger message; _args_ should be compatible
      # with something you would pass to Kernel::print.
      # 
      # Callers of this routine should make sure to use comma to
      # separate format argments rather than %. Otherwise it seems that
      # if the string you want to print has format specifier, which
      # could happen if you are trying to show say a source-code line
      # with "puts" or "print" in it, this print routine will give an
      # error saying it is looking for more arguments.
      def print(*args)
        @interface.print(*args)
      end

      # confirm is called before performing a dangerous action. 
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
  
  # A Debugger::ControlCommandProcessor is the kind of Debugger::Processor
  # used the debugged program is running remotely. It is also entered
  # after the debugged program has terminated.
  class ControlCommandProcessor < Processor
    def initialize(interface)
      super()
      @interface = interface
      @debugger_context_was_dead = true # Assume we haven't started.
    end

    # This the main debugger command-line loop. Here we read a
    # debugger command, perform it, and ask for another one unless we
    # are told to continue execution or terminate.
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

    # Return a prompt string to show before reading a command.  Note: The 
    # _context_ parameter is not used. It must be provided so that the 
    # interface matches Debugger::CommandProcessor#prompt.
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
      
      # Print a debugger error message; _args_ should be compatible
      # with something you would pass to Kernel::print.
      def errmsg(*args)
        @interface.print(*args)
      end
      
    # Print a normal debugger message; _args_ should be compatible
    # with something you would pass to Kernel::print.
    # 
    # Callers of this routine should make sure to use comma to
    # separate format argments rather than %. Otherwise it seems that
    # if the string you want to print has format specifier, which
    # could happen if you are trying to show say a source-code line
    # with "puts" or "print" in it, this print routine will give an
    # error saying it is looking for more arguments.
      def print(*args)
        @interface.print(*args)
      end

      # confirm is called before performing a dangerous action. In
      # control processor we always return "yes" or "y".
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
