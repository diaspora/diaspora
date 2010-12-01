if defined?(::HTTPClient)

  class ::HTTPClient

    def do_get_block_with_webmock(req, proxy, conn, &block)
      do_get_with_webmock(req, proxy, conn, false, &block)
    end

    def do_get_stream_with_webmock(req, proxy, conn, &block)
      do_get_with_webmock(req, proxy, conn, true, &block)
    end

    def do_get_with_webmock(req, proxy, conn, stream = false, &block)
      request_signature = build_request_signature(req)

      WebMock::RequestRegistry.instance.requested_signatures.put(request_signature)

      if WebMock::StubRegistry.instance.registered_request?(request_signature)
        webmock_response = WebMock::StubRegistry.instance.response_for_request(request_signature)
        response = build_httpclient_response(webmock_response, stream, &block)
        res = conn.push(response)
        WebMock::CallbackRegistry.invoke_callbacks(
          {:lib => :http_client}, request_signature, webmock_response) 
        res
      elsif WebMock.net_connect_allowed?(request_signature.uri)
        res = if stream
          do_get_stream_without_webmock(req, proxy, conn, &block)
        else
          do_get_block_without_webmock(req, proxy, conn, &block)
        end
        res = conn.pop
        conn.push(res)
        if WebMock::CallbackRegistry.any_callbacks?
          webmock_response = build_webmock_response(res)
          WebMock::CallbackRegistry.invoke_callbacks(
            {:lib => :http_client, :real_request => true}, request_signature,
            webmock_response)
        end
        res
      else
        raise WebMock::NetConnectNotAllowedError.new(request_signature)
      end
    end

    def do_request_async_with_webmock(method, uri, query, body, extheader)
      req = create_request(method, uri, query, body, extheader)
      request_signature = build_request_signature(req)
      
      if WebMock::StubRegistry.instance.registered_request?(request_signature) ||
         WebMock.net_connect_allowed?(request_signature.uri)
        do_request_async_without_webmock(method, uri, query, body, extheader)
      else
        raise WebMock::NetConnectNotAllowedError.new(request_signature)
      end
    end

    alias_method :do_get_block_without_webmock, :do_get_block
    alias_method :do_get_block, :do_get_block_with_webmock

    alias_method :do_get_stream_without_webmock, :do_get_stream
    alias_method :do_get_stream, :do_get_stream_with_webmock

    alias_method :do_request_async_without_webmock, :do_request_async
    alias_method :do_request_async, :do_request_async_with_webmock

    def build_httpclient_response(webmock_response, stream = false, &block)
      body = stream ? StringIO.new(webmock_response.body) : webmock_response.body
      response = HTTP::Message.new_response(body)
      response.header.init_response(webmock_response.status[0])
      response.reason=webmock_response.status[1]
      webmock_response.headers.to_a.each { |name, value| response.header.set(name, value) }

      raise HTTPClient::TimeoutError if webmock_response.should_timeout              
      webmock_response.raise_error_if_any

      block.call(nil, body) if block

      response
    end
  end
  
  def build_webmock_response(httpclient_response)
    webmock_response = WebMock::Response.new
    webmock_response.status = [httpclient_response.status, httpclient_response.reason]
    webmock_response.headers = httpclient_response.header.all
    if  httpclient_response.content.respond_to?(:read)
      webmock_response.body = httpclient_response.content.read
      body = HTTP::Message::Body.new
      body.init_response(StringIO.new(webmock_response.body))
      httpclient_response.body = body
    else
      webmock_response.body = httpclient_response.content
    end
    webmock_response
  end

  def build_request_signature(req)
    uri = WebMock::Util::URI.heuristic_parse(req.header.request_uri.to_s)
    uri.query_values = req.header.request_query if req.header.request_query
    uri.port = req.header.request_uri.port
    uri = uri.omit(:userinfo)

    auth = www_auth.basic_auth
    auth.challenge(req.header.request_uri, nil)
    
    headers = req.header.all.inject({}) do |headers, header| 
      headers[header[0]] ||= [];
      headers[header[0]] << header[1]
      headers
    end

    if (auth_cred = auth.get(req)) && auth.scheme == 'Basic'
      userinfo = WebMock::Util::Headers.decode_userinfo_from_header(auth_cred)
      userinfo = WebMock::Util::URI.encode_unsafe_chars_in_userinfo(userinfo)
      headers.reject! {|k,v| k =~ /[Aa]uthorization/ && v =~ /^Basic / } #we added it to url userinfo
      uri.userinfo = userinfo
    end

    request_signature = WebMock::RequestSignature.new(
      req.header.request_method.downcase.to_sym,
      uri.to_s,
      :body => req.body.content,
      :headers => headers
    )
  end

end
