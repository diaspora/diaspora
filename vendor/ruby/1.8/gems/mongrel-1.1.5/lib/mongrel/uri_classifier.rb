
module Mongrel
  class URIClassifier
  
    class RegistrationError < RuntimeError
    end
    class UsageError < RuntimeError
    end

    attr_reader :handler_map   
 
    # Returns the URIs that have been registered with this classifier so far.
    def uris
      @handler_map.keys
    end

    def initialize
      @handler_map = {}
      @matcher = //
      @root_handler = nil
    end
    
    # Register a handler object at a particular URI. The handler can be whatever 
    # you want, including an array. It's up to you what to do with it.
    #
    # Registering a handler is not necessarily threadsafe, so be careful if you go
    # mucking around once the server is running.
    def register(uri, handler)
      raise RegistrationError, "#{uri.inspect} is already registered" if @handler_map[uri]
      raise RegistrationError, "URI is empty" if !uri or uri.empty?
      raise RegistrationError, "URI must begin with a \"#{Const::SLASH}\"" unless uri[0..0] == Const::SLASH
      @handler_map[uri.dup] = handler
      rebuild
    end
    
    # Unregister a particular URI and its handler.
    def unregister(uri)
      handler = @handler_map.delete(uri)
      raise RegistrationError, "#{uri.inspect} was not registered" unless handler
      rebuild
      handler
    end
    
    # Resolve a request URI by finding the best partial match in the registered 
    # handler URIs.
    def resolve(request_uri)
      if @root_handler
        # Optimization for the pathological case of only one handler on "/"; e.g. Rails
        [Const::SLASH, request_uri, @root_handler]
      elsif match = @matcher.match(request_uri)
        uri = match.to_s
        # A root mounted ("/") handler must resolve such that path info matches the original URI.
        [uri, (uri == Const::SLASH ? request_uri : match.post_match), @handler_map[uri]]
      else
        [nil, nil, nil]
      end
    end
        
    private
    
    def rebuild
      if @handler_map.size == 1 and @handler_map[Const::SLASH]
        @root_handler = @handler_map.values.first
      else
        @root_handler = nil
        routes = @handler_map.keys.sort.sort_by do |uri|
          -uri.length
        end
        @matcher = Regexp.new(routes.map do |uri|
          Regexp.new('^' + Regexp.escape(uri))
        end.join('|'))
      end
    end    
    
  end
end