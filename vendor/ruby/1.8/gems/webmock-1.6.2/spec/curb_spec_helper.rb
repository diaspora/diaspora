module CurbSpecHelper
  def http_request(method, uri, options = {}, &block)
    uri = Addressable::URI.heuristic_parse(uri)
    body = options[:body]

    curl = curb_http_request(uri, method, body, options)

    status, response_headers = Curl::Easy::WebmockHelper.parse_header_string(curl.header_str)

    OpenStruct.new(
      :body => curl.body_str,
      :headers => WebMock::Util::Headers.normalize_headers(response_headers),
      :status => curl.response_code.to_s,
      :message => status
    )
  end

  def setup_request(uri, curl, options={})
    curl          ||= Curl::Easy.new
    curl.url      = uri.omit(:userinfo).to_s 
    curl.username = uri.user
    curl.password = uri.password
    curl.timeout  = 10
    curl.connect_timeout = 10

    if headers = options[:headers]
      headers.each {|k,v| curl.headers[k] = v }
    end

    curl
  end

  def client_timeout_exception_class
    Curl::Err::TimeoutError
  end

  def connection_refused_exception_class
    Curl::Err::ConnectionFailedError
  end

  def setup_expectations_for_real_request(options = {})
  end

  def http_library
    :curb
  end

  module DynamicHttp
    def curb_http_request(uri, method, body, options)
      curl = setup_request(uri, nil, options)

      case method
      when :post
        curl.post_body = body
      when :put
        curl.put_data = body
      end  

      curl.http(method)
      curl
    end
  end

  module NamedHttp
    def curb_http_request(uri, method, body, options)
      curl = setup_request(uri, nil, options)

      case method
      when :put, :post
        curl.send( "http_#{method}", body )
      else
        curl.send( "http_#{method}" )
      end
      curl
    end
  end

  module Perform
    def curb_http_request(uri, method, body, options)
      curl = setup_request(uri, nil, options)

      case method
      when :post
        curl.post_body = body
      when :put
        curl.put_data = body
      when :head
        curl.head = true
      when :delete
        curl.delete = true
      end

      curl.perform
      curl
    end
  end

  module ClassNamedHttp
    def curb_http_request(uri, method, body, options)
      args = ["http_#{method}", uri]
      args << body if method == :post || method == :put

      c = Curl::Easy.send(*args) do |curl|
        setup_request(uri, curl, options)
      end

      c
    end
  end

  module ClassPerform
    def curb_http_request(uri, method, body, options)
      args = ["http_#{method}", uri]
      args << body if method == :post || method == :put

      c = Curl::Easy.send(*args) do |curl|
        setup_request(uri, curl, options)

        case method
        when :post
          curl.post_body = body
        when :put
          curl.put_data = body
        when :head
          curl.head = true
        when :delete
          curl.delete = true
        end
      end

      c
    end
  end
end
