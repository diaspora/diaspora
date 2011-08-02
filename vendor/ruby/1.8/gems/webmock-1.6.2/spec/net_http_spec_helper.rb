module NetHTTPSpecHelper
  def http_request(method, uri, options = {}, &block)
    begin
      uri = URI.parse(uri)
    rescue
      uri = Addressable::URI.heuristic_parse(uri)
    end
    response = nil
    clazz = Net::HTTP.const_get("#{method.to_s.capitalize}")
    req = clazz.new("#{uri.path}#{uri.query ? '?' : ''}#{uri.query}", nil)
    options[:headers].each do |k,v| 
      if v.is_a?(Array)
        v.each_with_index do |v,i|
          i == 0 ? (req[k] = v) : req.add_field(k, v)
        end
      else
        req[k] = v
      end  
    end if options[:headers]

    req.basic_auth uri.user, uri.password if uri.user
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == "https"
      http.use_ssl = true
      #1.9.1 has a bug with ssl_timeout
      http.ssl_timeout = 10 unless RUBY_VERSION == "1.9.1"
    end
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = http.start {|http|
      http.request(req, options[:body], &block)
    }
    headers = {}
    response.each_header {|name, value| headers[name] = value}
    OpenStruct.new({
      :body => response.body,
      :headers => WebMock::Util::Headers.normalize_headers(headers),
      :status => response.code, 
      :message => response.message
    })
  end
  
  def client_timeout_exception_class
    Timeout::Error
  end

  def connection_refused_exception_class
    Errno::ECONNREFUSED
  end

  # Sets several expectations that a real HTTP request makes it
  # past WebMock to the socket layer. You can use this when you need to check
  # that a request isn't handled by WebMock
  #This solution is copied from FakeWeb project
  def setup_expectations_for_real_request(options = {})
    # Socket handling
    if options[:port] == 443
      socket = mock("SSLSocket")
      OpenSSL::SSL::SSLSocket.should_receive(:===).with(socket).at_least(:once).and_return(true)
      OpenSSL::SSL::SSLSocket.should_receive(:new).with(socket, instance_of(OpenSSL::SSL::SSLContext)).at_least(:once).and_return(socket)
      socket.stub!(:sync_close=).and_return(true)
      socket.should_receive(:connect).at_least(:once).with()
    else
      socket = mock("TCPSocket")
      Socket.should_receive(:===).with(socket).at_least(:once).and_return(true)
    end

    TCPSocket.should_receive(:open).with(options[:host], options[:port]).at_least(:once).and_return(socket)
    socket.stub!(:closed?).and_return(false)
    socket.stub!(:close).and_return(true)

    # Request/response handling
    request_parts = ["#{options[:method]} #{options[:path]} HTTP/1.1", "Host: #{options[:host]}"]
    socket.should_receive(:write).with(/#{request_parts[0]}.*#{request_parts[1]}.*/m).and_return(100)
    
    read_method = RUBY_VERSION >= "1.9.2" ? :read_nonblock : :sysread
    socket.should_receive(read_method).once.and_return("HTTP/1.1 #{options[:response_code]} #{options[:response_message]}\nContent-Length: #{options[:response_body].length}\n\n#{options[:response_body]}")
    socket.should_receive(read_method).any_number_of_times.and_raise(EOFError)
  end
  
  def http_library
    :net_http
  end
end
