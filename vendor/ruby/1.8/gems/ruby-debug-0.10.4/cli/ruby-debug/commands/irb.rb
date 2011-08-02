require 'irb'

module IRB # :nodoc:
  module ExtendCommand # :nodoc:

    # FIXME: should we read these out of a directory to 
    #        make this more user-customizable? 
    # A base command class that resume execution
    class DebuggerResumeCommand
      def self.execute(conf, *opts)
        name = 
          if self.name =~ /IRB::ExtendCommand::(\S+)/
            $1.downcase
          else
            'unknown'
          end
        $rdebug_args = opts
        $rdebug_command = 
          if $rdebug_irb_statements 
            $rdebug_irb_statements
          else
            ([name] + opts).join(' ')
          end

        throw :IRB_EXIT, name.to_sym
      end
    end

    class Continue < DebuggerResumeCommand ; end
    class Next     < DebuggerResumeCommand ; end
    class Quit     < DebuggerResumeCommand ; end
    class Step     < DebuggerResumeCommand ; end

    # Issues a comamnd to the debugger without continuing
    # execution. 
    class Dbgr
      def self.execute(conf, *opts)
        command = 
          if opts.size == 1 && opts[0].is_a?(String)
            args = opts[0]
          else
            opts.join(' ')
          end
        if $rdebug_state && $rdebug_state.processor
          processor = $rdebug_state.processor
          processor.one_cmd($rdebug_state.processor.commands, 
                            $rdebug_state.context,
                            command)
        end
      end
    end

  end
  if defined?(ExtendCommandBundle)
    [['cont', :Continue],
     ['dbgr', :Dbgr],
     ['n',    :Next],
     ['step', :Step],
     ['q',    :Quit]].each do |command, sym|
      ExtendCommandBundle.def_extend_command command, sym
    end
  end
  
  def self.start_session(binding)
    unless @__initialized
      args = ARGV.dup
      ARGV.replace([])
      IRB.setup(nil)
      ARGV.replace(args)

      # If the user has a IRB profile, run that now.
      if ENV['RDEBUG_IRB']
        ENV['IRBRC'] = ENV['RDEBUG_IRB']
        @CONF[:RC_NAME_GENERATOR]=nil
        IRB.run_config
      end
      @__initialized = true
    end
    
    workspace = WorkSpace.new(binding)

    irb = Irb.new(workspace)

    @CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC]
    @CONF[:MAIN_CONTEXT] = irb.context

    catch(:IRB_EXIT) do
      irb.eval_input
    end
  end
end

# Monkeypatch to save the current IRB statement to be run and make the instruction sequence
# "filename" unique. Possibly not needed.
class IRB::Context
  def evaluate(line, line_no)
    $rdebug_irb_statements = line
    @line_no = line_no
    set_last_value(@workspace.evaluate(self, line, irb_path, line_no))
#    @workspace.evaluate("_ = IRB.conf[:MAIN_CONTEXT]._")
#    @_ = @workspace.evaluate(line, irb_path, line_no)
  end
end

module Debugger

  # Implements debugger "irb" command.
  class IRBCommand < Command

    register_setting_get(:autoirb) do 
      IRBCommand.always_run
    end
    register_setting_set(:autoirb) do |value|
      IRBCommand.always_run = value
    end

    def regexp
      /^\s* irb
        (?:\s+(-d))?
        \s*$/x
    end
    
    def execute
      unless @state.interface.kind_of?(LocalInterface)
        print "Command is available only in local mode.\n"
        throw :debug_error
      end

      save_trap = trap("SIGINT") do
        throw :IRB_EXIT, :cont if $rdebug_in_irb
      end

      # add_debugging = @match.is_a?(Array) && '-d' == @match[1]
      $rdebug_state = @state
      $rdebug_in_irb = true
      cont = IRB.start_session(get_binding)
      case cont
      when :cont
        @state.proceed 
      when :step
        force = Command.settings[:force_stepping]
        @state.context.step(1, force)
        @state.proceed 
      when :next
        force = Command.settings[:force_stepping]
        @state.context.step_over(1, @state.frame_pos, force)
        @state.proceed 
      when :quit
        # FIXME: DRY with code from file/command quit.
        if confirm("Really quit? (y/n) ") 
          @state.interface.finalize
          exit! # exit -> exit!: No graceful way to stop threads...
        end
      else
        file = @state.context.frame_file(0)
        line = @state.context.frame_line(0)
        CommandProcessor.print_location_and_text(file, line)
        @state.previous_line = nil
      end

    ensure
      $rdebug_in_irb = nil
      $rdebug_state = nil
      trap("SIGINT", save_trap) if save_trap
    end
    
    class << self
      def help_command
        'irb'
      end

      def help(cmd)
        %{
          irb [-d]\tstarts an Interactive Ruby (IRB) session.

If -d is added you can get access to debugger state via the global variable
$rdebug_state. 

irb is extended with methods "cont", "n", "step" and "q" which run the
corresponding debugger commands. In contrast to the real debugger
commands these commands do not allow command arguments.

However to run any arbitrary rdebug command which does not involve
execution of the debugged program (like the above "step" "cont", etc.)
use method "dbgr" and give an array of string parameters. For example:

dbgr ['list', '10']   # same as "list 10" inside debugger
        }
      end
    end
  end
end

