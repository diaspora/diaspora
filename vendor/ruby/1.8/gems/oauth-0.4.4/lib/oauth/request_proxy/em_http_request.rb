require 'oauth/request_proxy/base'
# em-http also uses adddressable so there is no need to require uri.
require 'em-http'
require 'cgi'

module OAuth::RequestProxy::EventMachine
  class HttpRequest < OAuth::RequestProxy::Base

    # A Proxy for use when you need to sign EventMachine::HttpClient instances.
    # It needs to be called once the client is construct but before data is sent.
    # Also see oauth/client/em-http
    proxies ::EventMachine::HttpClient

    # Request in this con

    def method
      request.method
    end

    def uri
      request.normalize_uri.to_s
    end

    def parameters
      if options[:clobber_request]
        options[:parameters]
      else
        all_parameters
      end
    end

    protected

    def all_parameters
      merged_parameters({}, post_parameters, query_parameters, options[:parameters])
    end

    def query_parameters
      CGI.parse(request.normalize_uri.query.to_s)
    end

    def post_parameters
      headers = request.options[:head] || {}
      form_encoded = headers['Content-Type'].to_s.downcase == 'application/x-www-form-urlencoded'
      if ['POST', 'PUT'].include?(method) && form_encoded
        CGI.parse(request.normalize_body.to_s)
      else
        {}
      end
    end

    def merged_parameters(params, *extra_params)
      extra_params.compact.each do |params_pairs|
        params_pairs.each_pair do |key, value|
          if params.has_key?(key)
            params[key] += value
          else
            params[key] = [value].flatten
          end
        end
      end
      params
    end

  end
end
