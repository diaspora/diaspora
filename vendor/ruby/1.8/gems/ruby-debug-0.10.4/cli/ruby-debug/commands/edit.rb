module Debugger
  class Edit < Command # :nodoc:
    self.allow_in_control = true
    def regexp
      /^\s* ed(?:it)? (?:\s+(.*))?$/ix
    end
    
    def execute
      if not @match[1] or @match[1].strip.empty?
        unless @state.context
          errmsg "We are not in a state that has an associated file.\n"
          return 
        end
        file = @state.file
        line_number = @state.line
      elsif @pos_match = /([^:]+)[:]([0-9]+)/.match(@match[1])
        file, line_number = @pos_match.captures
      else
        errmsg "Invalid file/line number specification: #{@match[1]}\n"
        return
      end
      editor = ENV['EDITOR'] || 'ex'
      if File.readable?(file)
        system("#{editor} +#{line_number} #{file}")
      else
        errmsg "File \"#{file}\" is not readable.\n"
      end
    end
    
    class << self
      def help_command
        'edit'
      end

      def help(cmd)
        %{
          Edit specified file.

With no argument, edits file containing most recent line listed.
Editing targets can also be specified in this:
  FILE:LINENUM, to edit at that line in that file,
        }
      end
    end
  end


end # module Debugger
