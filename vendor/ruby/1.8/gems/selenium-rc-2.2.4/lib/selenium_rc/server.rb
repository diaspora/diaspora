module SeleniumRC

  class Server
    attr_accessor :host
    attr_accessor :port
    attr_accessor :args
    attr_accessor :timeout

    def self.boot(*args)
      new(*args).boot
    end

    def initialize(host, port = nil, options = {})
      @host = host
      @port = port || 4444
      @args = options[:args] || []
      @timeout = options[:timeout]
    end

    def boot
      start
      wait
      stop_at_exit
      self
    end

    def log(string)
      puts string
    end

    def start
      command = "java -jar \"#{jar_path}\""
      command << " -port #{port}"
      command << " #{args.join(' ')}" unless args.empty?
      log "Running: #{command}"
      begin
        fork do
          system(command)
        end
      rescue NotImplementedError
        Thread.start do
          system(command)
        end
      end
    end

    def stop_at_exit
      at_exit do
        stop
      end
    end

    def jar_path
      File.expand_path("#{File.dirname(__FILE__)}/../../vendor/selenium-server.jar")
    end

    def wait
      $stderr.print "==> Waiting for Selenium RC server on port #{port}... "
      wait_for_service_with_timeout
      $stderr.print "Ready!\n"
    rescue SocketError
      fail
    end

    def fail
      $stderr.puts
      $stderr.puts
      $stderr.puts "==> Failed to boot the Selenium RC server... exiting!"
      exit
    end

    def stop
      Net::HTTP.get(host, '/selenium-server/driver/?cmd=shutDownSeleniumServer', port)
    end

    def service_is_running?
      begin
        socket = TCPSocket.new(host, port)
        socket.close unless socket.nil?
        true
      rescue Errno::ECONNREFUSED,
             Errno::EBADF,           # Windows
             Errno::EADDRNOTAVAIL    # Windows
        false
      end
    end

    protected
    def wait_for_service_with_timeout
      start_time = Time.now
      timeout = 60

      until service_is_running?
        if timeout && (Time.now > (start_time + timeout))
          raise SocketError.new("Socket did not open within #{timeout} seconds")
        end
      end
    end
  end

end
