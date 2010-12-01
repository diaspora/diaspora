module Debugger
  # Mix-in module to assist in command parsing.
  module EnableDisableFunctions # :nodoc:
    def enable_disable_breakpoints(is_enable, args)
      breakpoints = Debugger.breakpoints.sort_by{|b| b.id }
      largest = breakpoints.inject(0) do |largest, b| 
        largest = b.id if b.id > largest
      end
      if 0 == largest
        errmsg "No breakpoints have been set.\n"
        return
      end
      args.each do |pos|
        pos = get_int(pos, "#{is_enable} breakpoints", 1, largest)
        return nil unless pos
        breakpoints.each do |b|
          if b.id == pos 
            enabled = ("Enable" == is_enable)
            if enabled
              unless syntax_valid?(b.expr)
                errmsg("Expression \"#{b.expr}\" syntactically incorrect; breakpoint remains disabled.\n")
                break
              end
            end
            b.enabled = ("Enable" == is_enable)
            break
          end
        end
      end
    end

    def enable_disable_display(is_enable, args)
      if 0 == @state.display.size 
        errmsg "No display expressions have been set.\n"
        return
      end
      args.each do |pos|
        pos = get_int(pos, "#{is_enable} display", 1, @state.display.size)
        return nil unless pos
        @state.display[pos-1][0] = ("Enable" == is_enable)
      end
    end

  end

  class EnableCommand < Command # :nodoc:
    Subcommands = 
      [
       ['breakpoints', 2, "Enable specified breakpoints",
"Give breakpoint numbers (separated by spaces) as arguments.
This is used to cancel the effect of the \"disable\" command."
       ],
       ['display', 2, 
        "Enable some expressions to be displayed when program stops",
"Arguments are the code numbers of the expressions to resume displaying.
Do \"info display\" to see current list of code numbers."],
      ].map do |name, min, short_help, long_help| 
      SubcmdStruct.new(name, min, short_help, long_help)
    end unless defined?(Subcommands)

    def regexp
      /^\s* en(?:able)? (?:\s+(.*))?$/ix
    end
    
    def execute
      if not @match[1]
        errmsg "\"enable\" must be followed \"display\", \"breakpoints\"" +
          " or breakpoint numbers.\n"
      else
        args = @match[1].split(/[ \t]+/)
        param = args.shift
        subcmd = find(Subcommands, param)
        if subcmd
          send("enable_#{subcmd.name}", args)
        else
          send("enable_breakpoints", args.unshift(param))
        end
      end
    end
    
    def enable_breakpoints(args)
      enable_disable_breakpoints("Enable", args)
    end
    
    def enable_display(args)
      enable_disable_display("Enable", args)
    end
    
    class << self
      def help_command
        'enable'
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
            return "Invalid 'enable' subcommand '#{args[1]}'."
          end
        end
        s = %{
          Enable some things.
          This is used to cancel the effect of the "disable" command.
          -- 
          List of enable subcommands:
          --  
        }
        for subcmd in Subcommands do
          s += "enable #{subcmd.name} -- #{subcmd.short_help}\n"
        end
        return s
      end
    end
  end

  class DisableCommand < Command # :nodoc:
    Subcommands = 
      [
       ['breakpoints', 1, "Disable some breakpoints",
"Arguments are breakpoint numbers with spaces in between.
A disabled breakpoint is not forgotten, but has no effect until reenabled."],
       ['display', 1, "Disable some display expressions when program stops",
"Arguments are the code numbers of the expressions to stop displaying.
Do \"info display\" to see current list of code numbers."],
      ].map do |name, min, short_help, long_help| 
      SubcmdStruct.new(name, min, short_help, long_help)
    end unless defined?(Subcommands)

    def regexp
      /^\s* dis(?:able)? (?:\s+(.*))?$/ix
    end
    
    def execute
      if not @match[1]
        errmsg "\"disable\" must be followed \"display\", \"breakpoints\"" +
          " or breakpoint numbers.\n"
      else
        args = @match[1].split(/[ \t]+/)
        param = args.shift
        subcmd = find(Subcommands, param)
        if subcmd
          send("disable_#{subcmd.name}", args)
        else
          send("disable_breakpoints", args.unshift(param))
        end
      end
    end
    
    def disable_breakpoints(args)
      enable_disable_breakpoints("Disable", args)
    end
    
    def disable_display(args)
      enable_disable_display("Disable", args)
    end
    
    class << self
      def help_command
        'disable'
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
            return "Invalid 'disable' subcommand '#{args[1]}'."
          end
        end
        s = %{
          Disable some things.

          A disabled item is not forgotten, but has no effect until reenabled.
          Use the "enable" command to have it take effect again.
          -- 
          List of disable subcommands:
          --  
        }
        for subcmd in Subcommands do
          s += "disable #{subcmd.name} -- #{subcmd.short_help}\n"
        end
        return s
      end
    end
  end

end # module Debugger
