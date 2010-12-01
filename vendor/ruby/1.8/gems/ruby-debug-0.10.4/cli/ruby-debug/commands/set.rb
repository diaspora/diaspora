module Debugger
  # Implements debugger "set" command.
  class SetCommand < Command
    SubcmdStruct2=Struct.new(:name, :min, :is_bool, :short_help, 
                             :long_help) unless defined?(SubcmdStruct2)
    Subcommands = 
      [
       ['annotate', 2, false,
       "Set annotation level",
"0 == normal;
2 == output annotated suitably for use by programs that control 
ruby-debug."],
       ['args', 2, false,
       "Set argument list to give program being debugged when it is started",
"Follow this command with any number of args, to be passed to the program."],
       ['autoeval', 4, true,
        "Evaluate every unrecognized command"],
       ['autolist', 4, true,
        "Execute 'list' command on every breakpoint"],
       ['autoirb', 4, true,
        "Invoke IRB on every stop"],
       ['autoreload', 4, true,
        "Reload source code when changed"],
       ['basename', 1, true,
        "Report file basename only showing file names"],
       ['callstyle', 2, false,
        "Set how you want call parameters displayed"],
       ['debuggertesting', 8, false,
        "Used when testing the debugger"],
       ['forcestep', 2, true,
        "Make sure 'next/step' commands always move to a new line"],
       ['fullpath', 2, true,
        "Display full file names in frames"],
       ['history', 2, false,
        "Generic command for setting command history parameters",
"set history filename -- Set the filename in which to record the command history
set history save -- Set saving of the history record on exit
set history size -- Set the size of the command history"],
       ['keep-frame-bindings', 1, true,
        "Save frame binding on each call"],
       ['linetrace+', 10, true,
       "Set line execution tracing to show different lines"],
       ['linetrace', 3, true,
       "Set line execution tracing"],
       ['listsize', 3, false,
       "Set number of source lines to list by default"],
#        ['post-mortem', 3, true,
#        "Set whether we do post-mortem handling on an uncaught exception"],
       ['trace', 1, true,
        "Display stack trace when 'eval' raises exception"],
       ['width', 1, false,
        "Number of characters the debugger thinks are in a line"],
      ].map do |name, min, is_bool, short_help, long_help| 
      SubcmdStruct2.new(name, min, is_bool, short_help, long_help)
    end unless defined?(Subcommands)
    
    self.allow_in_control = true

    def regexp
      /^set (?: \s+ (.*) )?$/ix
    end

    def execute
      if not @match[1]
        print "\"set\" must be followed by the name of an set command:\n"
        print "List of set subcommands:\n\n"
        for subcmd in Subcommands do
          print "set #{subcmd.name} -- #{subcmd.short_help}\n"
        end
      else
        args = @match[1].split(/[ \t]+/)
        subcmd = args.shift
        subcmd.downcase!
        if subcmd =~ /^no/i
          set_on = false
          subcmd = subcmd[2..-1]
        else
          set_on = true
        end
        for try_subcmd in Subcommands do
          if (subcmd.size >= try_subcmd.min) and
              (try_subcmd.name[0..subcmd.size-1] == subcmd)
            begin
              if try_subcmd.is_bool
                if args.size > 0 
                  set_on = get_onoff(args[0]) 
                end
              end
              case try_subcmd.name
              when /^annotate$/
                level = get_int(args[0], "Set annotate", 0, 3, 0)
                if level
                  Debugger.annotate = level
                else
                  return
                end
                if defined?(Debugger::RDEBUG_SCRIPT)
                  # rdebug was called initially. 1st arg is script name.
                  Command.settings[:argv][1..-1] = args
                else
                  # rdebug wasn't called initially. 1st arg is not script name.
                  Command.settings[:argv] = args
                end
              when /^args$/
                Command.settings[:argv][1..-1] = args
              when /^autolist$/
                Command.settings[:autolist] = (set_on ? 1 : 0)
              when /^autoeval$/
                Command.settings[:autoeval] = set_on
              when /^basename$/
                Command.settings[:basename] = set_on
              when /^callstyle$/
                if args[0]
                  arg = args[0].downcase.to_sym
                  case arg
                  when :short, :last, :tracked
                    Command.settings[:callstyle] = arg
                    Debugger.track_frame_args = arg == :tracked ? true : false
                    print "%s\n" % show_setting(try_subcmd.name)
                    return
                  end
                end
                print "Invalid call style #{arg}. Should be one of: " +
                  "'short', 'last', or 'tracked'.\n"
              when /^trace$/
                Command.settings[:stack_trace_on_error] = set_on
              when /^fullpath$/
                Command.settings[:full_path] = set_on
              when /^autoreload$/
                Command.settings[:reload_source_on_change] = set_on
              when /^autoirb$/
                Command.settings[:autoirb] = (set_on ? 1 : 0)
              when /^debuggertesting$/
                Command.settings[:debuggertesting] = set_on
                if set_on
                  Command.settings[:basename] = true
                end
              when /^forcestep$/
                self.class.settings[:force_stepping] = set_on
              when /^history$/
                if 2 == args.size
                  interface = @state.interface
                  case args[0]
                  when /^save$/
                    interface.history_save = get_onoff(args[1])
                  when /^size$/
                    interface.history_length = get_int(args[1],
                                                       "Set history size")
                  else
                    print "Invalid history parameter #{args[0]}. Should be 'save' or 'size'.\n" 
                  end
                else
                  print "Need two parameters for 'set history'; got #{args.size}.\n" 
                  return
                end
              when /^keep-frame-bindings$/
                Debugger.keep_frame_binding = set_on
              when /^linetrace\+$/
                self.class.settings[:tracing_plus] = set_on
              when /^linetrace$/
                Debugger.tracing = set_on
              when /^listsize$/
                listsize = get_int(args[0], "Set listsize", 1, nil, 10)
                if listsize
                  self.class.settings[:listsize] = listsize
                else
                  return
                end
#               when /^post-mortem$/
#                 unless Debugger.post_mortem? == set_on
#                   if set_on
#                     Debugger.post_mortem
#                   else
#                     errmsg "Can't turn off post-mortem once it is on.\n"
#                     return
#                   end
#                 end
              when /^width$/
                width = get_int(args[0], "Set width", 10, nil, 80)
                if width
                  self.class.settings[:width] = width
                  ENV['COLUMNS'] = width.to_s
                else
                  return
                end
              else
                print "Unknown setting #{@match[1]}.\n"
                return
              end
              print "%s\n" % show_setting(try_subcmd.name)
              return
            rescue RuntimeError
              return
            end
          end
        end
        print "Unknown set command #{subcmd}\n"
      end
    end

    class << self
      def help_command
        "set"
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
            str += "\n" + subcmd.long_help if subcmd.long_help
            return str
          else
            return "Invalid 'set' subcommand '#{args[1]}'."
          end
        end
        s = %{
          Modifies parts of the ruby-debug environment. Boolean values take
          on, off, 1 or 0.
          You can see these environment settings with the \"show\" command.

          -- 
          List of set subcommands:
          --  
        }
        for subcmd in Subcommands do
          s += "set #{subcmd.name} -- #{subcmd.short_help}\n"
        end
        return s
      end
    end
  end
end
