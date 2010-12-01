module Debugger

  def inside_emacs?
    ENV['EMACS'] || ENV['INSIDE_EMACS']
  end
  module_function :inside_emacs?
  
  module ParseFunctions
    Position_regexp = '(?:(\d+)|(.+?)[:.#]([^.:\s]+))'

    # Parse 'str' of command 'cmd' as an integer between
    # min and max. If either min or max is nil, that
    # value has no bound.
    def get_int(str, cmd, min=nil, max=nil, default=1)
      return default unless str
      begin
        int = Integer(str)
        if min and int < min
          print "%s argument '%s' needs to at least %s.\n" % [cmd, str, min]
          return nil
        elsif max and int > max
          print "%s argument '%s' needs to at most %s.\n" % [cmd, str, max]
          return nil
        end
        return int
      rescue
        print "%s argument '%s' needs to be a number.\n" % [cmd, str]
        return nil
      end
    end

    # Return true if arg is 'on' or 1 and false arg is 'off' or 0.
    # Any other value raises RuntimeError.
    def get_onoff(arg, default=nil, print_error=true)
      if arg.nil? or arg == ''
        if default.nil?
          if print_error
            print "Expecting 'on', 1, 'off', or 0. Got nothing.\n"
            raise RuntimeError
          end
          return default
        end
      end
      case arg.downcase
      when '1', 'on'
        return true
      when '0', 'off'
        return false
      else
        if print_error
          print "Expecting 'on', 1, 'off', or 0. Got: %s.\n" % arg.to_s
          raise RuntimeError
        end
      end
    end

    # Return 'on' or 'off' for supplied parameter. The parmeter should
    # be true, false or nil.
    def show_onoff(bool)
      if not [TrueClass, FalseClass, NilClass].member?(bool.class)
        return "??"
      end
      return bool ? 'on' : 'off'
    end

    # Return true if code is syntactically correct for Ruby.
    def syntax_valid?(code)
      eval("BEGIN {return true}\n#{code}", nil, "", 0)
    rescue Exception
      false
    end 

  end
end
