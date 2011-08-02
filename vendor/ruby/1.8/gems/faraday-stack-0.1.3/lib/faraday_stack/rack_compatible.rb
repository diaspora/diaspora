require 'stringio'

module FaradayStack
  # Wraps a handler originally written for Rack to make it compatible with Faraday.
  #
  # Experimental. Only handles changes in request headers.
  class RackCompatible
    def initialize(app, rack_handler, *args)
      # tiny middleware that decomposes a Faraday::Response to standard Rack
      # array: [status, headers, body]
      compatible_app = lambda do |env|
        restore_env(env)
        response = app.call(env)
        [response.status, response.headers, Array(response.body)]
      end
      @rack = rack_handler.new(compatible_app, *args)
    end
    
    def call(env)
      prepare_env(env)
      rack_response = @rack.call(env)
      finalize_response(env, rack_response)
    end
    
    NonPrefixedHeaders = %w[CONTENT_LENGTH CONTENT_TYPE]
    
    # faraday to rack-compatible
    def prepare_env(env)
      env[:request_headers].each do |name, value|
        name = name.upcase.tr('-', '_')
        name = "HTTP_#{name}" unless NonPrefixedHeaders.include? name
        env[name] = value
      end
      
      url = env[:url]
      env['rack.url_scheme'] = url.scheme
      env['PATH_INFO'] = url.path
      env['SERVER_PORT'] = url.inferred_port
      env['QUERY_STRING'] = url.query
      env['REQUEST_METHOD'] = env[:method].to_s.upcase
      
      env['rack.errors'] ||= StringIO.new
      
      env
    end
    
    # rack to faraday-compatible
    def restore_env(env)
      headers = env[:request_headers]
      headers.clear
      
      env.each do |name, value|
        next unless String === name
        if NonPrefixedHeaders.include? name or name.index('HTTP_') == 0
          name = name.sub(/^HTTP_/).downcase.tr('_', '-')
          headers[name] = value
        end
      end
      
      env[:method] = env['REQUEST_METHOD'].downcase.to_sym
      env
    end
    
    def finalize_response(env, rack_response)
      status, headers, body = rack_response
      body = body.inject('') { |str, part| str << part }
      headers = Faraday::Utils::Headers.new(headers) unless Faraday::Utils::Headers === headers
      
      response_env = { :status => status, :body => body, :response_headers => headers }
      
      env[:response] ||= Faraday::Response.new({})
      env[:response].env.update(response_env)
      env[:response]
    end
  end
end
