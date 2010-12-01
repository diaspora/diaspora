require 'yaml'
require 'etc'

module Mongrel
  # Implements a simple DSL for configuring a Mongrel server for your 
  # purposes.  More used by framework implementers to setup Mongrel
  # how they like, but could be used by regular folks to add more things
  # to an existing mongrel configuration.
  #
  # It is used like this:
  #
  #   require 'mongrel'
  #   config = Mongrel::Configurator.new :host => "127.0.0.1" do
  #     listener :port => 3000 do
  #       uri "/app", :handler => Mongrel::DirHandler.new(".", load_mime_map("mime.yaml"))
  #     end
  #     run
  #   end
  # 
  # This will setup a simple DirHandler at the current directory and load additional
  # mime types from mimy.yaml.  The :host => "127.0.0.1" is actually not 
  # specific to the servers but just a hash of default parameters that all 
  # server or uri calls receive.
  #
  # When you are inside the block after Mongrel::Configurator.new you can simply
  # call functions that are part of Configurator (like server, uri, daemonize, etc)
  # without having to refer to anything else.  You can also call these functions on 
  # the resulting object directly for additional configuration.
  #
  # A major thing about Configurator is that it actually lets you configure 
  # multiple listeners for any hosts and ports you want.  These are kept in a
  # map config.listeners so you can get to them.
  #
  # * :pid_file => Where to write the process ID.
  class Configurator
    attr_reader :listeners
    attr_reader :defaults
    attr_reader :needs_restart

    # You pass in initial defaults and then a block to continue configuring.
    def initialize(defaults={}, &block)
      @listener = nil
      @listener_name = nil
      @listeners = {}
      @defaults = defaults
      @needs_restart = false
      @pid_file = defaults[:pid_file]

      if block
        cloaker(&block).bind(self).call
      end
    end

    # Change privileges of the process to specified user and group.
    def change_privilege(user, group)
      begin
        uid, gid = Process.euid, Process.egid
        target_uid = Etc.getpwnam(user).uid if user
        target_gid = Etc.getgrnam(group).gid if group

        if uid != target_uid or gid != target_gid
          log "Initiating groups for #{user.inspect}:#{group.inspect}."
          Process.initgroups(user, target_gid)
        
          log "Changing group to #{group.inspect}."
          Process::GID.change_privilege(target_gid)

          log "Changing user to #{user.inspect}." 
          Process::UID.change_privilege(target_uid)
        end
      rescue Errno::EPERM => e
        log "Couldn't change user and group to #{user.inspect}:#{group.inspect}: #{e.to_s}."
        log "Mongrel failed to start."
        exit 1
      end
    end

    def remove_pid_file
      File.unlink(@pid_file) if @pid_file and File.exists?(@pid_file)
    end

    # Writes the PID file if we're not on Windows.
    def write_pid_file
      if RUBY_PLATFORM !~ /mswin/
        log "Writing PID file to #{@pid_file}"
        open(@pid_file,"w") {|f| f.write(Process.pid) }
        open(@pid_file,"w") do |f|
          f.write(Process.pid)
          File.chmod(0644, @pid_file)
        end      
      end
    end

    # Generates a class for cloaking the current self and making the DSL nicer.
    def cloaking_class
      class << self
        self
      end
    end

    # Do not call this.  You were warned.
    def cloaker(&block)
      cloaking_class.class_eval do
        define_method :cloaker_, &block
        meth = instance_method( :cloaker_ )
        remove_method :cloaker_
        meth
      end
    end

    # This will resolve the given options against the defaults.
    # Normally just used internally.
    def resolve_defaults(options)
      options.merge(@defaults)
    end

    # Starts a listener block.  This is the only one that actually takes
    # a block and then you make Configurator.uri calls in order to setup
    # your URIs and handlers.  If you write your Handlers as GemPlugins
    # then you can use load_plugins and plugin to load them.
    # 
    # It expects the following options (or defaults):
    # 
    # * :host => Host name to bind.
    # * :port => Port to bind.
    # * :num_processors => The maximum number of concurrent threads allowed.
    # * :throttle => Time to pause (in hundredths of a second) between accepting clients. 
    # * :timeout => Time to wait (in seconds) before killing a stalled thread.
    # * :user => User to change to, must have :group as well.
    # * :group => Group to change to, must have :user as well.
    #
    def listener(options={},&block)
      raise "Cannot call listener inside another listener block." if (@listener or @listener_name)
      ops = resolve_defaults(options)
      ops[:num_processors] ||= 950
      ops[:throttle] ||= 0
      ops[:timeout] ||= 60

      @listener = Mongrel::HttpServer.new(ops[:host], ops[:port].to_i, ops[:num_processors].to_i, ops[:throttle].to_i, ops[:timeout].to_i)
      @listener_name = "#{ops[:host]}:#{ops[:port]}"
      @listeners[@listener_name] = @listener

      if ops[:user] and ops[:group]
        change_privilege(ops[:user], ops[:group])
      end

      # Does the actual cloaking operation to give the new implicit self.
      if block
        cloaker(&block).bind(self).call
      end

      # all done processing this listener setup, reset implicit variables
      @listener = nil
      @listener_name = nil
    end


    # Called inside a Configurator.listener block in order to 
    # add URI->handler mappings for that listener.  Use this as
    # many times as you like.  It expects the following options
    # or defaults:
    #
    # * :handler => HttpHandler -- Handler to use for this location.
    # * :in_front => true/false -- Rather than appending, it prepends this handler.
    def uri(location, options={})
      ops = resolve_defaults(options)
      @listener.register(location, ops[:handler], ops[:in_front])
    end


    # Daemonizes the current Ruby script turning all the
    # listeners into an actual "server" or detached process.
    # You must call this *before* frameworks that open files
    # as otherwise the files will be closed by this function.
    #
    # Does not work for Win32 systems (the call is silently ignored).
    #
    # Requires the following options or defaults:
    #
    # * :cwd => Directory to change to.
    # * :log_file => Where to write STDOUT and STDERR.
    # 
    # It is safe to call this on win32 as it will only require the daemons
    # gem/library if NOT win32.
    def daemonize(options={})
      ops = resolve_defaults(options)
      # save this for later since daemonize will hose it
      if RUBY_PLATFORM !~ /mswin/
        require 'daemons/daemonize'

        logfile = ops[:log_file]
        if logfile[0].chr != "/"
          logfile = File.join(ops[:cwd],logfile)
          if not File.exist?(File.dirname(logfile))
            log "!!! Log file directory not found at full path #{File.dirname(logfile)}.  Update your configuration to use a full path."
            exit 1
          end
        end

        Daemonize.daemonize(logfile)

        # change back to the original starting directory
        Dir.chdir(ops[:cwd])

      else
        log "WARNING: Win32 does not support daemon mode."
      end
    end


    # Uses the GemPlugin system to easily load plugins based on their
    # gem dependencies.  You pass in either an :includes => [] or 
    # :excludes => [] setting listing the names of plugins to include
    # or exclude from the determining the dependencies.
    def load_plugins(options={})
      ops = resolve_defaults(options)

      load_settings = {}
      if ops[:includes]
        ops[:includes].each do |plugin|
          load_settings[plugin] = GemPlugin::INCLUDE
        end
      end

      if ops[:excludes]
        ops[:excludes].each do |plugin|
          load_settings[plugin] = GemPlugin::EXCLUDE
        end
      end

      GemPlugin::Manager.instance.load(load_settings)
    end


    # Easy way to load a YAML file and apply default settings.
    def load_yaml(file, default={})
      default.merge(YAML.load_file(file))
    end


    # Loads the MIME map file and checks that it is correct
    # on loading.  This is commonly passed to Mongrel::DirHandler
    # or any framework handler that uses DirHandler to serve files.
    # You can also include a set of default MIME types as additional
    # settings.  See Mongrel::DirHandler for how the MIME types map
    # is organized.
    def load_mime_map(file, mime={})
      # configure any requested mime map
      mime = load_yaml(file, mime)

      # check all the mime types to make sure they are the right format
      mime.each {|k,v| log "WARNING: MIME type #{k} must start with '.'" if k.index(".") != 0 }

      return mime
    end


    # Loads and creates a plugin for you based on the given
    # name and configured with the selected options.  The options
    # are merged with the defaults prior to passing them in.
    def plugin(name, options={})
      ops = resolve_defaults(options)
      GemPlugin::Manager.instance.create(name, ops)
    end

    # Lets you do redirects easily as described in Mongrel::RedirectHandler.
    # You use it inside the configurator like this:
    #
    #   redirect("/test", "/to/there") # simple
    #   redirect("/to", /t/, 'w') # regexp
    #   redirect("/hey", /(w+)/) {|match| ...}  # block
    #
    def redirect(from, pattern, replacement = nil, &block)
      uri from, :handler => Mongrel::RedirectHandler.new(pattern, replacement, &block)
    end

    # Works like a meta run method which goes through all the 
    # configured listeners.  Use the Configurator.join method
    # to prevent Ruby from exiting until each one is done.
    def run
      @listeners.each {|name,s| 
        s.run 
      }

      $mongrel_sleeper_thread = Thread.new { loop { sleep 1 } }
    end

    # Calls .stop on all the configured listeners so they
    # stop processing requests (gracefully).  By default it
    # assumes that you don't want to restart.
    def stop(needs_restart=false, synchronous=false)   
      @listeners.each do |name,s| 
        s.stop(synchronous)      
      end      
      @needs_restart = needs_restart
    end


    # This method should actually be called *outside* of the
    # Configurator block so that you can control it.  In other words
    # do it like:  config.join.
    def join
      @listeners.values.each {|s| s.acceptor.join }
    end


    # Calling this before you register your URIs to the given location
    # will setup a set of handlers that log open files, objects, and the
    # parameters for each request.  This helps you track common problems
    # found in Rails applications that are either slow or become unresponsive
    # after a little while.
    #
    # You can pass an extra parameter *what* to indicate what you want to 
    # debug.  For example, if you just want to dump rails stuff then do:
    #
    #   debug "/", what = [:rails]
    # 
    # And it will only produce the log/mongrel_debug/rails.log file.
    # Available options are: :access, :files, :objects, :threads, :rails 
    # 
    # NOTE: Use [:files] to get accesses dumped to stderr like with WEBrick.
    def debug(location, what = [:access, :files, :objects, :threads, :rails])
      require 'mongrel/debug'
      handlers = {
        :access => "/handlers/requestlog::access", 
        :files => "/handlers/requestlog::files", 
        :objects => "/handlers/requestlog::objects", 
        :threads => "/handlers/requestlog::threads",
        :rails => "/handlers/requestlog::params"
      }

      # turn on the debugging infrastructure, and ObjectTracker is a pig
      MongrelDbg.configure

      # now we roll through each requested debug type, turn it on and load that plugin
      what.each do |type| 
        MongrelDbg.begin_trace type 
        uri location, :handler => plugin(handlers[type])
      end
    end

    # Used to allow you to let users specify their own configurations
    # inside your Configurator setup.  You pass it a script name and
    # it reads it in and does an eval on the contents passing in the right
    # binding so they can put their own Configurator statements.
    def run_config(script)
      open(script) {|f| eval(f.read, proc {self}) }
    end

    # Sets up the standard signal handlers that are used on most Ruby
    # It only configures if the platform is not win32 and doesn't do
    # a HUP signal since this is typically framework specific.
    #
    # Requires a :pid_file option given to Configurator.new to indicate a file to delete.  
    # It sets the MongrelConfig.needs_restart attribute if 
    # the start command should reload.  It's up to you to detect this
    # and do whatever is needed for a "restart".
    #
    # This command is safely ignored if the platform is win32 (with a warning)
    def setup_signals(options={})
      ops = resolve_defaults(options)

      # forced shutdown, even if previously restarted (actually just like TERM but for CTRL-C)
      trap("INT") { log "INT signal received."; stop(false) }

      # clean up the pid file always
      at_exit { remove_pid_file }

      if RUBY_PLATFORM !~ /mswin/
        # graceful shutdown
        trap("TERM") { log "TERM signal received."; stop }
        trap("USR1") { log "USR1 received, toggling $mongrel_debug_client to #{!$mongrel_debug_client}"; $mongrel_debug_client = !$mongrel_debug_client }
        # restart
        trap("USR2") { log "USR2 signal received."; stop(true) }

        log "Signals ready.  TERM => stop.  USR2 => restart.  INT => stop (no restart)."
      else
        log "Signals ready.  INT => stop (no restart)."
      end
    end

    # Logs a simple message to STDERR (or the mongrel log if in daemon mode).
    def log(msg)
      STDERR.print "** ", msg, "\n"
    end

  end
end
