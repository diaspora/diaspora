module OAuth
  module RequestProxy
    def self.available_proxies #:nodoc:
      @available_proxies ||= {}
    end

    def self.proxy(request, options = {})
      return request if request.kind_of?(OAuth::RequestProxy::Base)

      klass = available_proxies[request.class]

      # Search for possible superclass matches.
      if klass.nil?
        request_parent = available_proxies.keys.find { |rc| request.kind_of?(rc) }
        klass = available_proxies[request_parent]
      end

      raise UnknownRequestType, request.class.to_s unless klass
      klass.new(request, options)
    end

    class UnknownRequestType < Exception; end
  end
end
