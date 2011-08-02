require 'open-uri'
require 'logger'
require 'optparse'
require 'fileutils'

if Vegas::WINDOWS
  begin
    require 'win32/process'
  rescue
    puts "Sorry, in order to use Vegas on Windows you need the win32-process gem:",
         "gem install win32-process"
  end
end

module Vegas
  class Runner
    attr_reader :app, :app_name, :filesystem_friendly_app_name, :quoted_app_name,
      :rack_handler, :port, :host, :options, :args

    ROOT_DIR   = File.expand_path(File.join('~', '.vegas'))
    PORT       = 5678
    HOST       = WINDOWS ? 'localhost' : '0.0.0.0'

    def initialize(app, app_name, set_options = {}, runtime_args = ARGV, &block)
      @options = set_options || {}

      self.class.logger.level = options[:debug] ? Logger::DEBUG : Logger::INFO

      @app      = app
      @app_name = app_name

      @filesystem_friendly_app_name = @app_name.gsub(/\W+/, "_")
      @quoted_app_name = "'#{app_name}'"

      @runtime_args = runtime_args
      @rack_handler = setup_rack_handler

      # load options from opt parser
      @args = define_options do |opts|
        if block_given?
          opts.separator ''
          opts.separator "#{quoted_app_name} options:"
          yield(self, opts, app)
        end
      end

      if @should_kill
        kill!
        exit!(0)
      end

      # Handle :before_run hook
      if (before_run = options.delete(:before_run)).respond_to?(:call)
        before_run.call(self)
      end

      # Set app options
      @host = options[:host] || HOST

      if app.respond_to?(:set)
        app.set(options)
        app.set(:vegas, self)
      end

      # Make sure app dir is setup
      FileUtils.mkdir_p(app_dir)

      return if options[:start] == false

      # evaluate the launch_path
      path = if options[:launch_path].respond_to?(:call)
        options[:launch_path].call(self)
      else
        options[:launch_path]
      end

      start(path)
    end

    def app_dir
      options[:app_dir] || File.join(ROOT_DIR, filesystem_friendly_app_name)
    end

    def pid_file
      options[:pid_file] || File.join(app_dir, "#{filesystem_friendly_app_name}.pid")
    end

    def url_file
      options[:url_file] || File.join(app_dir, "#{filesystem_friendly_app_name}.url")
    end

    def log_file
      options[:log_file] || File.join(app_dir, "#{filesystem_friendly_app_name}.log")
    end

    def url
      "http://#{host}:#{port}"
    end

    def start(path = nil)
      logger.info "Running with Windows Settings" if WINDOWS
      logger.info "Starting #{quoted_app_name}..."
      begin
        check_for_running(path)
        find_port
        write_url
        launch!(url, path)
        daemonize! unless options[:foreground]
        run!
      rescue RuntimeError => e
        logger.warn "There was an error starting #{quoted_app_name}: #{e}"
        exit
      end
    end

    def find_port
      if @port = options[:port]
        announce_port_attempted

        unless port_open?
          logger.warn "Port #{port} is already in use. Please try another. " +
                      "You can also omit the port flag, and we'll find one for you."
        end
      else
        @port = PORT
        announce_port_attempted

        until port_open?
          @port += 1
          announce_port_attempted
        end
      end
    end

    def announce_port_attempted
      logger.info "trying port #{port}..."
    end

    def port_open?(check_url = nil)
      begin
        check_url ||= url
        options[:no_proxy] ? open(check_url, :proxy => nil) : open(check_url)
        false
      rescue Errno::ECONNREFUSED => e
        true
      rescue Errno::EPERM => e
        # catches the "Operation not permitted" under Cygwin
        true
      end
    end

    def write_url
      File.open(url_file, 'w') {|f| f << url }
    end

    def check_for_running(path = nil)
      if File.exists?(pid_file) && File.exists?(url_file)
        running_url = File.read(url_file)
        if !port_open?(running_url)
          logger.warn "#{quoted_app_name} is already running at #{running_url}"
          launch!(running_url, path)
          exit!(1)
        end
      end
    end

    def run!
      logger.info "Running with Rack handler: #{@rack_handler.inspect}"

      rack_handler.run app, :Host => host, :Port => port do |server|
        trap(kill_command) do
          ## Use thins' hard #stop! if available, otherwise just #stop
          server.respond_to?(:stop!) ? server.stop! : server.stop
          logger.info "#{quoted_app_name} received INT ... stopping"
          delete_pid!
        end
      end
    end

    # Adapted from Rackup
    def daemonize!
      if RUBY_VERSION < "1.9"
        logger.debug "Parent Process: #{Process.pid}"
        exit!(0) if fork
        logger.debug "Child Process: #{Process.pid}"
      else
        Process.daemon(true, true)
      end

      File.umask 0000
      FileUtils.touch log_file
      STDIN.reopen    log_file
      STDOUT.reopen   log_file, "a"
      STDERR.reopen   log_file, "a"

      logger.debug "Child Process: #{Process.pid}"

      File.open(pid_file, 'w') {|f| f.write("#{Process.pid}") }
      at_exit { delete_pid! }
    end

    def launch!(specific_url = nil, path = nil)
      return if options[:skip_launch]
      cmd = WINDOWS ? "start" : "open"
      system "#{cmd} #{specific_url || url}#{path}"
    end

    def kill!
      pid = File.read(pid_file)
      logger.warn "Sending INT to #{pid.to_i}"
      Process.kill(kill_command, pid.to_i)
    rescue => e
      logger.warn "pid not found at #{pid_file} : #{e}"
    end

    def status
      if File.exists?(pid_file)
        logger.info "#{quoted_app_name} running"
        logger.info "PID #{File.read(pid_file)}"
        logger.info "URL #{File.read(url_file)}" if File.exists?(url_file)
      else
        logger.info "#{quoted_app_name} not running!"
      end
    end

    # Loads a config file at config_path and evals it in the context of the @app.
    def load_config_file(config_path)
      abort "Can not find config file at #{config_path}" if !File.readable?(config_path)
      config = File.read(config_path)
      # trim off anything after __END__
      config.sub!(/^__END__\n.*/, '')
      @app.module_eval(config)
    end

    def self.logger=(logger)
      @logger = logger
    end

    def self.logger
      @logger ||= LOGGER if defined?(LOGGER)
      if !@logger
        @logger           = Logger.new(STDOUT)
        @logger.formatter = Proc.new {|s, t, n, msg| "[#{t}] #{msg}\n"}
        @logger
      end
      @logger
    end

    def logger
      self.class.logger
    end

  private
    def setup_rack_handler
      # First try to set Rack handler via a special hook we honor
      @rack_handler = if @app.respond_to?(:detect_rack_handler)
        @app.detect_rack_handler

      # If they aren't using our hook, try to use their @app.server settings
      elsif @app.respond_to?(:server) and @app.server
        # If :server isn't set, it returns an array of possibilities,
        # sorted from most to least preferable.
        if @app.server.is_a?(Array)
          handler = nil
          @app.server.each do |server|
            begin
              handler = Rack::Handler.get(server)
              break
            rescue LoadError, NameError => e
              next
            end
          end
          handler

        # :server might be set explicitly to a single option like "mongrel"
        else
          Rack::Handler.get(@app.server)
        end

      # If all else fails, we'll use Thin
      else
        Rack::Handler::Thin
      end
    end

    def define_options
      OptionParser.new("", 24, '  ') do |opts|
        # TODO instead of app_name, we should determine the name of the script
        # used to invoke Vegas and use that here
        opts.banner = "Usage: #{$0 || app_name} [options]"

        opts.separator ""
        opts.separator "Vegas options:"

        opts.on('-K', "--kill", "kill the running process and exit") {|k|
          @should_kill = true
        }

        opts.on('-S', "--status", "display the current running PID and URL then quit") {|s|
          status
          exit!(0)
        }

        opts.on("-s", "--server SERVER", "serve using SERVER (thin/mongrel/webrick)") { |s|
          @rack_handler = Rack::Handler.get(s)
        }

        opts.on("-o", "--host HOST", "listen on HOST (default: #{HOST})") { |host|
          @options[:host] = host
        }

        opts.on("-p", "--port PORT", "use PORT (default: #{PORT})") { |port|
          @options[:port] = port
        }

        opts.on("-x", "--no-proxy", "ignore env proxy settings (e.g. http_proxy)") { |p|
          @options[:no_proxy] = true
        }

        opts.on("-e", "--env ENVIRONMENT", "use ENVIRONMENT for defaults (default: development)") { |e|
          @options[:environment] = e
        }

        opts.on("-F", "--foreground", "don't daemonize, run in the foreground") { |f|
          @options[:foreground] = true
        }

        opts.on("-L", "--no-launch", "don't launch the browser") { |f|
          @options[:skip_launch] = true
        }

        opts.on('-d', "--debug", "raise the log level to :debug (default: :info)") {|s|
          @options[:debug] = true
        }

        opts.on("--app-dir APP_DIR", "set the app dir where files are stored (default: ~/.vegas/#{filesystem_friendly_app_name})/)") {|app_dir|
          @options[:app_dir] = app_dir
        }

        opts.on("-P", "--pid-file PID_FILE", "set the path to the pid file (default: app_dir/#{filesystem_friendly_app_name}.pid)") {|pid_file|
          @options[:pid_file] = pid_file
        }

        opts.on("--log-file LOG_FILE", "set the path to the log file (default: app_dir/#{filesystem_friendly_app_name}.log)") {|log_file|
          @options[:log_file] = log_file
        }

        opts.on("--url-file URL_FILE", "set the path to the URL file (default: app_dir/#{filesystem_friendly_app_name}.url)") {|url_file|
          @options[:url_file] = url_file
        }

        yield opts if block_given?

        opts.separator ""
        opts.separator "Common options:"

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on_tail("--version", "Show version") do
          if app.respond_to?(:version)
            puts "#{quoted_app_name} #{app.version}"
          end
          puts "rack #{Rack::VERSION.join('.')}"
          puts "sinatra #{Sinatra::VERSION}" if defined?(Sinatra)
          puts "vegas #{Vegas::VERSION}"
          exit
        end

      end.parse! @runtime_args
    rescue OptionParser::MissingArgument => e
      logger.warn "#{e}, run -h for options"
      exit
    end

    def kill_command
      WINDOWS ? 1 : :INT
    end

    def delete_pid!
      File.delete(pid_file) if File.exist?(pid_file)
    end
  end

end
