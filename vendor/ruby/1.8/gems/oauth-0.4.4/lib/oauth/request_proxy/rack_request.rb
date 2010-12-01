require 'oauth/request_proxy/base'
require 'uri'
require 'rack'

module OAuth::RequestProxy
  class RackRequest < OAuth::RequestProxy::Base
    proxies Rack::Request

    def method
      request.env["rack.methodoverride.original_method"] || request.request_method
    end

    def uri
      request.url
    end

    def parameters
      if options[:clobber_request]
        options[:parameters] || {}
      else
        params = request_params.merge(query_params).merge(header_params)
        params.merge(options[:parameters] || {})
      end
    end

    def signature
      parameters['oauth_signature']
    end

  protected

    def query_params
      request.GET
    end

    def request_params
      request.POST
    end
  end
end
