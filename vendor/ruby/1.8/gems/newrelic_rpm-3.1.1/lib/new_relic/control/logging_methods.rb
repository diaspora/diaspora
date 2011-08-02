
module NewRelic
  class Control
    # Contains methods that relate to locating, creating, and writing
    # to the log file and/or standard out
    module LoggingMethods

      attr_accessor :log_file
      
      # returns either the log set up with setup_log or else a new
      # logger pointing to standard out, if we're trying to log before
      # a log exists
      def log
        if !@log
          l = Logger.new(STDOUT)
          l.level = Logger::INFO          
          return l
        end
        @log
      end

      # send the given message to STDOUT so that it shows
      # up in the console.  This should be used for important informational messages at boot.
      # The to_stdout may be implemented differently by different config subclasses.
      # This will NOT print anything if tracers are not enabled
      def log!(msg, level=:info)
        to_stdout msg
        return unless should_log?
        log.send level, msg if @log
      end
      
      # true if the agent has settings, and the agent is enabled,
      # otherwise false
      def should_log?
        @settings && agent_enabled?
      end

      # set the log level as specified in the config file
      #
      # Possible values are from the Logger class: debug, info, warn,
      #error, and fatal
      # Defaults to info
      def set_log_level!(logger)
        case fetch("log_level","info").downcase
          when "debug" then logger.level = Logger::DEBUG
          when "info" then logger.level = Logger::INFO
          when "warn" then logger.level = Logger::WARN
          when "error" then logger.level = Logger::ERROR
          when "fatal" then logger.level = Logger::FATAL
          else logger.level = Logger::INFO
        end
        logger
      end

      # patches the logger's format_message method to change the format just for our logger
      def set_log_format!(logger)
        def logger.format_message(severity, timestamp, progname, msg)
          prefix = @logdev.dev == STDOUT ? '** [NewRelic]' : ''
          prefix + "[#{timestamp.strftime("%m/%d/%y %H:%M:%S %z")} #{Socket.gethostname} (#{$$})] #{severity} : #{msg}\n"
        end
        logger
      end

      # Create the logger using the configuration variables
      #
      # Control subclasses may override this, but it can be called multiple times.
      def setup_log
        if log_to_stdout?
          @log = Logger.new(STDOUT) 
        else
          @log_file = "#{log_path}/#{log_file_name}"
          @log = Logger.new(@log_file) rescue nil
          @log ||= Logger.new(STDOUT) # failsafe to STDOUT
        end
        
        if @log
          set_log_format!(@log)
          set_log_level!(@log)
        end
        # note this is not the variable from above - it is the `log`
        # method, which returns a default logger if none is setup
        # above
        log
      end
      
      # simply puts a message to standard out, prepended with the
      # '** [NewRelic]' sigil to make sure people know where the message
      # comes from. This should be used sparingly
      def to_stdout(msg)
        STDOUT.puts "** [NewRelic] " + msg
      end
      
      # Sets up and caches the log path, attempting to create it if it
      # does not exist. this comes from the configuration variable
      # 'log_file_path' in the configuration file.
      def log_path
        return @log_path if @log_path
        if log_to_stdout?
          @log_path = nil
        else
          @log_path = find_or_create_file_path(fetch('log_file_path', 'log'))
          log!("Error creating log directory for New Relic log file, using standard out.", :error) unless @log_path
        end
        @log_path
      end
        
      def find_or_create_file_path(path_setting)
        for abs_path in [ File.expand_path(path_setting),
                          File.expand_path(File.join(root, path_setting)) ] do
          if File.directory?(abs_path) || (Dir.mkdir(abs_path) rescue nil)
            return abs_path[%r{^(.*?)/?$}]
          end
        end
        nil
      end

      def log_to_stdout?
        return true if @stdout
        if fetch('log_file_path', 'log') == 'STDOUT'
          @stdout = true
        end
      end
        
      # Retrieves the log file's name from the config file option
      #'log_file_name', defaulting to 'newrelic_agent.log'
      def log_file_name
        fetch('log_file_name', 'newrelic_agent.log')
      end
    end
    include LoggingMethods
  end
end
