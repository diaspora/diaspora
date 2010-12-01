module HTTPClientSpecHelper
  class << self
    attr_accessor :async_mode
  end
  
  def http_request(method, uri, options = {}, &block)
    uri = Addressable::URI.heuristic_parse(uri)
    c = HTTPClient.new
    c.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
    c.set_basic_auth(nil, uri.user, uri.password) if uri.user
    params = [method, "#{uri.omit(:userinfo, :query).normalize.to_s}",
      uri.query_values, options[:body], options[:headers] || {}]
    if HTTPClientSpecHelper.async_mode
      connection = c.request_async(*params)
      connection.join
      response = connection.pop
    else
      response = c.request(*params, &block)
    end
    headers = response.header.all.inject({}) do |headers, header| 
      if !headers.has_key?(header[0])
        headers[header[0]] = header[1]
      else
        headers[header[0]] = [headers[header[0]], header[1]].join(', ')
      end
      headers
    end
    OpenStruct.new({
      :body => HTTPClientSpecHelper.async_mode ? response.content.read : response.content,
      :headers => headers,
      :status => response.code.to_s,
      :message => response.reason
    })
  end

  def client_timeout_exception_class
    HTTPClient::TimeoutError
  end

  def connection_refused_exception_class
    Errno::ECONNREFUSED
  end

  def setup_expectations_for_real_request(options = {})
    socket = mock("TCPSocket")
    TCPSocket.should_receive(:new).
      with(options[:host], options[:port]).at_least(:once).and_return(socket)

    socket.stub!(:closed?).and_return(false)
    socket.stub!(:close).and_return(true)

    request_parts = ["#{options[:method]} #{options[:path]} HTTP/1.1", "Host: #{options[:host]}"]

    if options[:port] == 443
      OpenSSL::SSL::SSLSocket.should_receive(:new).
        with(socket, instance_of(OpenSSL::SSL::SSLContext)).
        at_least(:once).and_return(socket = mock("SSLSocket"))
      socket.should_receive(:connect).at_least(:once).with()
      socket.should_receive(:peer_cert).and_return(mock('peer cert', :extensions => []))
      socket.should_receive(:write).with(/#{request_parts[0]}.*#{request_parts[1]}.*/m).and_return(100)
    else
      socket.should_receive(:<<).with(/#{request_parts[0]}.*#{request_parts[1]}.*/m).and_return(100)
    end

    socket.stub!(:sync=).with(true)

    socket.should_receive(:gets).with("\n").once.and_return("HTTP/1.1 #{options[:response_code]} #{options[:response_message]}\nContent-Length: #{options[:response_body].length}\n\n#{options[:response_body]}")

    socket.stub!(:eof?).and_return(true)
    socket.stub!(:close).and_return(true)

    socket.should_receive(:readpartial).any_number_of_times.and_raise(EOFError)
  end
  
  def http_library
    :http_client
  end

end
