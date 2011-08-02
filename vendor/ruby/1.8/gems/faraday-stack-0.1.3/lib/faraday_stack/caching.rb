module FaradayStack
  class Caching < Faraday::Middleware
    attr_reader :cache
    
    def initialize(app, cache = nil, options = {})
      super(app)
      @cache = cache || Proc.new.call
      @options = options
    end
    
    def call(env)
      if :get == env[:method]
        if env[:parallel_manager]
          # callback mode
          cache_on_complete(env)
        else
          # synchronous mode
          response = cache.fetch(cache_key(env)) { @app.call(env) }
          finalize_response(response, env)
        end
      else
        @app.call(env)
      end
    end
    
    def cache_key(env)
      url = env[:url].dup
      if url.query && params_to_strip.any?
        url.query_values = url.query_values.reject { |k,| params_to_strip.include? k }
      end
      url.normalize!
      url.request_uri
    end
    
    def params_to_strip
      @params_to_strip ||= Array(@options[:strip_params]).map { |p| p.to_s }
    end
    
    def cache_on_complete(env)
      key = cache_key(env)
      if cached_response = cache.read(key)
        finalize_response(cached_response, env)
      else
        response = @app.call(env)
        response.on_complete { cache.write(key, response) }
      end
    end
    
    def finalize_response(response, env)
      response = env[:response] = response.dup if response.frozen?
      response.apply_request env unless response.env[:method]
      response
    end
  end
end
