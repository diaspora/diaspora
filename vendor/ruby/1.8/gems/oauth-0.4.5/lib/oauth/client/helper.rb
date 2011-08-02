require 'oauth/client'
require 'oauth/consumer'
require 'oauth/helper'
require 'oauth/token'
require 'oauth/signature/hmac/sha1'

module OAuth::Client
  class Helper
    include OAuth::Helper

    def initialize(request, options = {})
      @request = request
      @options = options
      @options[:signature_method] ||= 'HMAC-SHA1'
    end

    def options
      @options
    end

    def nonce
      options[:nonce] ||= generate_key
    end

    def timestamp
      options[:timestamp] ||= generate_timestamp
    end

    def oauth_parameters
      {
        'oauth_body_hash'        => options[:body_hash],
        'oauth_callback'         => options[:oauth_callback],
        'oauth_consumer_key'     => options[:consumer].key,
        'oauth_token'            => options[:token] ? options[:token].token : '',
        'oauth_signature_method' => options[:signature_method],
        'oauth_timestamp'        => timestamp,
        'oauth_nonce'            => nonce,
        'oauth_verifier'         => options[:oauth_verifier],
        'oauth_version'          => (options[:oauth_version] || '1.0'),
        'oauth_session_handle'   => options[:oauth_session_handle]
      }.reject { |k,v| v.to_s == "" }
    end

    def signature(extra_options = {})
      OAuth::Signature.sign(@request, { :uri      => options[:request_uri],
                                        :consumer => options[:consumer],
                                        :token    => options[:token],
                                        :unsigned_parameters => options[:unsigned_parameters]
      }.merge(extra_options) )
    end

    def signature_base_string(extra_options = {})
      OAuth::Signature.signature_base_string(@request, { :uri        => options[:request_uri],
                                                         :consumer   => options[:consumer],
                                                         :token      => options[:token],
                                                         :parameters => oauth_parameters}.merge(extra_options) )
    end

    def hash_body
      @options[:body_hash] = OAuth::Signature.body_hash(@request, :parameters => oauth_parameters)
    end

    def amend_user_agent_header(headers)
      @oauth_ua_string ||= "OAuth gem v#{OAuth::VERSION}"
      # Net::HTTP in 1.9 appends Ruby
      if headers['User-Agent'] && headers['User-Agent'] != 'Ruby'
        headers['User-Agent'] += " (#{@oauth_ua_string})"
      else
        headers['User-Agent'] = @oauth_ua_string
      end
    end

    def header
      parameters = oauth_parameters
      parameters.merge!('oauth_signature' => signature(options.merge(:parameters => parameters)))

      header_params_str = parameters.sort.map { |k,v| "#{k}=\"#{escape(v)}\"" }.join(', ')

      realm = "realm=\"#{options[:realm]}\", " if options[:realm]
      "OAuth #{realm}#{header_params_str}"
    end

    def parameters
      OAuth::RequestProxy.proxy(@request).parameters
    end

    def parameters_with_oauth
      oauth_parameters.merge(parameters)
    end
  end
end
