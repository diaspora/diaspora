module Debugger
  module SaveFunctions # :nodoc:

    # Create a temporary file to write in if file is nil
    def open_save
      require "tempfile"
      file = Tempfile.new("rdebug-save")
      # We want close to not unlink, so redefine.
      def file.close
        @tmpfile.close if @tmpfile
      end
      return file
    end
  end

  class SaveCommand < Command # :nodoc:
    self.allow_in_control = true
    
    def save_breakpoints(file)
      Debugger.breakpoints.each do |b|
        file.puts "break #{b.source}:#{b.pos}#{" if #{b.expr}" if b.expr}"
      end
    end

    def save_catchpoints(file)
      Debugger.catchpoints.keys.each do |c|
        file.puts "catch #{c}" 
      end
    end
    
    def save_displays(file)
      for d in @state.display
        if d[0]
          file.puts "display #{d[1]}"
        end
      end
    end
    
    def save_settings(file)
      # FIXME put routine in set
      %w(autoeval basename debuggertesting).each do |setting|
        on_off = show_onoff(Command.settings[setting.to_sym])
        file.puts "set #{setting} #{on_off}"
      end
      %w(autolist autoirb).each do |setting|
        on_off = show_onoff(Command.settings[setting.to_sym] > 0)
        file.puts "set #{setting} #{on_off}"
      end
    end
    
    def regexp
      /^\s* sa(?:ve)?
        (?:\s+(.+))? 
        \s*$/ix
    end
    
    def execute
      if not @match[1] or @match[1].strip.empty?
        file = open_save()
      else
        file = open(@match[1], 'w')
      end
      save_breakpoints(file)
      save_catchpoints(file)
      # save_displays(file)
      save_settings(file)
      print "Saved to '#{file.path}'\n"
      if @state and @state.interface
        @state.interface.restart_file = file.path
      end
      file.close
    end

    class << self
      def help_command
        'save'
      end
      
      def help(cmd)
        %{
save [FILE]
Saves current debugger state to FILE as a script file.
This includes breakpoints, catchpoints, display expressions and some settings.
If no filename is given, we will fabricate one.

Use the 'source' command in another debug session to restore them.}
      end
    end
  end
end
