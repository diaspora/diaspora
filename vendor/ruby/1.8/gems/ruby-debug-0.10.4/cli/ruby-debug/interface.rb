module Debugger  
  
  # An _Interface_ is the kind of input/output interaction that goes
  # on between the user and the debugged program. It includes things
  # like how one wants to show error messages, or read input. This is
  # the base class. Subclasses inlcude Debugger::LocalInterface,
  # Debugger::RemoteInterface and Debugger::ScriptInterface.
  class Interface 
    attr_writer :have_readline  # true if Readline is available

    def initialize
      begin
        require 'readline'
        @have_readline = true
        @history_save = true
      rescue LoadError
        @have_readline = false
        @history_save = false
      end
    end

    # Common routine for reporting debugger error messages.
    # Derived classed may want to override this to capture output.
    def errmsg(*args)
      if Debugger.annotate.to_i > 2
        aprint 'error-begin'
        print(*args)
        aprint ''
      else
        print '*** '
        print(*args)
      end
    end
    
    # Format msg with gdb-style annotation header
    def afmt(msg, newline="\n")
      "\032\032#{msg}#{newline}"
    end

    def aprint(msg)
      print afmt(msg)
    end

    # Things we do before terminating.
    def finalize
    end
    
  end

  # A _LocalInterface_ is the kind of I/O interactive performed when
  # the user interface is in the same process as the debugged program.
  # Compare with Debugger::RemoteInterface.
  class LocalInterface < Interface
    attr_accessor :command_queue
    attr_accessor :histfile
    attr_accessor :history_save
    attr_accessor :history_length
    attr_accessor :restart_file

    unless defined?(FILE_HISTORY)
      FILE_HISTORY = ".rdebug_hist"
    end
    def initialize()
      super
      @command_queue = []
      @restart_file = nil

      if @have_readline
        # take gdb's default
        @history_length = ENV['HISTSIZE'] ? ENV['HISTSIZE'].to_i : 256  
        @histfile = File.join(ENV['HOME']||ENV['HOMEPATH']||'.', 
                              FILE_HISTORY)
        open(@histfile, 'r') do |file|
          file.each do |line|
            line.chomp!
            Readline::HISTORY << line
          end
        end if File.exist?(@histfile)
      end
    end

    def read_command(prompt)
      readline(prompt, true)
    end
    
    def confirm(prompt)
      readline(prompt, false)
    end
    
    def print(*args)
      STDOUT.printf(*args)
    end
    
    def close
    end

    # Things to do before quitting
    def finalize
      if Debugger.method_defined?("annotate") and Debugger.annotate.to_i > 2
        print "\032\032exited\n\n" 
      end
      if Debugger.respond_to?(:save_history)
        Debugger.save_history 
      end
    end
    
    def readline_support?
      @have_readline
    end

    private
    begin
      require 'readline'
      class << Debugger
        @have_readline = true
        define_method(:save_history) do
          iface = self.handler.interface
          iface.histfile ||= File.join(ENV['HOME']||ENV['HOMEPATH']||'.', 
                                  FILE_HISTORY)
          open(iface.histfile, 'w') do |file|
            Readline::HISTORY.to_a.last(iface.history_length).each do |line|
              file.puts line unless line.strip.empty?
            end if defined?(iface.history_save) and iface.history_save
          end rescue nil
        end
        public :save_history 
      end
      Debugger.debug_at_exit do 
        finalize if respond_to?(:finalize)
      end
      
      def readline(prompt, hist)
        Readline::readline(prompt, hist)
      end
    rescue LoadError
      def readline(prompt, hist)
        @histfile = ''
        @hist_save = false
        STDOUT.print prompt
        STDOUT.flush
        line = STDIN.gets
        exit unless line
        line.chomp!
        line
      end
    end
  end

  # A _RemoteInterface_ is the kind of I/O interactive performed when
  # the user interface is in a different process (and possibly
  # different computer) than the debugged program.  Compare with
  # Debugger::LocalInterface.
  class RemoteInterface < Interface
    attr_accessor :command_queue
    attr_accessor :histfile
    attr_accessor :history_save
    attr_accessor :history_length
    attr_accessor :restart_file

    def initialize(socket)
      @command_queue = []
      @socket = socket
      @history_save = false
      @history_length = 256
      @histfile = ''
      # Do we read the histfile?
#       open(@histfile, 'r') do |file|
#         file.each do |line|
#           line.chomp!
#           Readline::HISTORY << line
#         end
#       end if File.exist?(@histfile)
      @restart_file = nil
    end
    
    def close
      @socket.close
    rescue Exception
    end
    
    def confirm(prompt)
      send_command "CONFIRM #{prompt}"
    end

    def read_command(prompt)
      send_command "PROMPT #{prompt}"
    end
    
    def readline_support?
      false
    end

    def print(*args)
      @socket.printf(*args)
    end
    
    private
    
    def send_command(msg)
      @socket.puts msg
      result = @socket.gets
      raise IOError unless result
      result.chomp
    end
  end
  
  # A _ScriptInterface_ is used when we are reading debugger commands
  # from a command-file rather than an interactive user. Command files
  # appear in a users initialization script (e.g. .rdebugrc) and appear
  # when running the debugger command _source_ (Debugger::SourceCommand).
  class ScriptInterface < Interface
    attr_accessor :command_queue
    attr_accessor :histfile
    attr_accessor :history_save
    attr_accessor :history_length
    attr_accessor :restart_file
    def initialize(file, out, verbose=false)
      super()
      @command_queue = []
      @file = file.respond_to?(:gets) ? file : open(file)
      @out = out
      @verbose = verbose
      @history_save = false
      @history_length = 256  # take gdb default
      @histfile = ''
    end

    def read_command(prompt)
      while result = @file.gets
        puts "# #{result}" if @verbose
        next if result =~ /^\s*#/
        next if result.strip.empty?
        break
      end
      raise IOError unless result
      result.chomp!
    end
    
    # Do we have ReadLine support? When running an debugger command
    # script, we are not interactive so we just return _false_.
    def readline_support?
      false
    end

    # _confirm_ is called before performing a dangerous action. In
    # running a debugger script, we don't want to prompt, so we'll pretend
    # the user has unconditionally said "yes" and return String "y".
    def confirm(prompt)
      'y'
    end
    
    def print(*args)
      @out.printf(*args)
    end
    
    def close
      @file.close
    end
  end
end
