require 'uri'
require 'net/http'
require 'rack'

class Capybara::Server
  class Identify
    def initialize(app)
      @app = app
    end

    def call(env)
      if env["PATH_INFO"] == "/__identify__"
        [200, {}, @app.object_id.to_s]
      else
        @app.call(env)
      end
    end
  end

  attr_reader :app, :port

  def initialize(app)
    @app = app
  end

  def host
    "localhost" 
  end

  def url(path)
    if path =~ /^http/
      path
    else
      (Capybara.app_host || "http://#{host}:#{port}") + path.to_s
    end
  end

  def responsive?
    is_running_on_port?(port)
  end

  def handler
    begin
      require 'rack/handler/thin'
      Rack::Handler::Thin
    rescue LoadError
      begin
        require 'rack/handler/mongrel'
        Rack::Handler::Mongrel
      rescue LoadError
        require 'rack/handler/webrick'
        Rack::Handler::WEBrick
      end
    end
  end

  def boot
    return self unless @app
    find_available_port
    Capybara.log "application has already booted" and return self if responsive?
    Capybara.log "booting Rack applicartion on port #{port}"

    Thread.new do
      handler.run(Identify.new(@app), :Port => port, :AccessLog => [])
    end
    Capybara.log "checking if application has booted"

    Capybara::WaitUntil.timeout(10) do
      if responsive?
        Capybara.log("application has booted")
        true
      else
        sleep 0.5
        false
      end
    end
    self
  rescue Timeout::Error
    Capybara.log "Rack application timed out during boot"
    exit
  end

private

  def find_available_port
    @port = 9887
    @port += 1 while is_port_open?(@port) and not is_running_on_port?(@port)
  end

  def is_running_on_port?(tested_port)
    res = Net::HTTP.start(host, tested_port) { |http| http.get('/__identify__') }

    if res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
      return res.body == @app.object_id.to_s
    end
  rescue Errno::ECONNREFUSED, Errno::EBADF
    return false
  end

  def is_port_open?(tested_port)
    Timeout::timeout(1) do
      begin
        s = TCPSocket.new(host, tested_port)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        return false
      end
    end
  rescue Timeout::Error
    return false
  end

end
