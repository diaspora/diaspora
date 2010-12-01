module Debugger
  module DisplayFunctions # :nodoc:
    def display_expression(exp)
      print "%s = %s\n", exp, debug_silent_eval(exp).to_s
    end
    
    def active_display_expressions?
      @state.display.select{|d| d[0]}.size > 0
    end

    def print_display_expressions
      n = 1
      for d in @state.display
        if d[0]
          print "%d: ", n
          display_expression(d[1])
        end
        n += 1
      end
    end
  end

  class AddDisplayCommand < Command # :nodoc:
    def regexp
      /^\s*disp(?:lay)?\s+(.+)$/
    end

    def execute
      exp = @match[1]
      @state.display.push [true, exp]
      print "%d: ", @state.display.size
      display_expression(exp)
    end

    class << self
      def help_command
        'display'
      end

      def help(cmd)
        %{
          disp[lay] <expression>\tadd expression into display expression list
        }
      end
    end
  end

  class DisplayCommand < Command # :nodoc:
    def self.always_run 
      Debugger.annotate = 0 unless Debugger.annotate
      if Debugger.annotate > 1 
        0
      else
        2
      end
    end
    
    def regexp
      /^\s*disp(?:lay)?$/
    end

    def execute
      print_display_expressions
    end

    class << self
      def help_command
        'display'
      end

      def help(cmd)
        %{
          disp[lay]\t\tdisplay expression list
        }
      end
    end
  end

  class DeleteDisplayCommand < Command # :nodoc:

    def regexp
      /^\s* undisp(?:lay)? \s* (?:(\S+))?$/x
    end

    def execute
      unless pos = @match[1]
        if confirm("Clear all expressions? (y/n) ")
          for d in @state.display
            d[0] = false
          end
        end
      else
        pos = get_int(pos, "Undisplay")
        return unless pos
        if @state.display[pos-1]
          @state.display[pos-1][0] = nil
        else
          errmsg "Display expression %d is not defined.\n", pos
        end
      end
    end

    class << self
      def help_command
        'undisplay'
      end

      def help(cmd)
        %{
          undisp[lay][ nnn]
          Cancel some expressions to be displayed when program stops.
          Arguments are the code numbers of the expressions to stop displaying.
          No argument means cancel all automatic-display expressions.
          "delete display" has the same effect as this command.
          Do "info display" to see current list of code numbers.
        }
      end
    end
  end
end
