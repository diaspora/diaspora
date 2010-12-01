require 'oauth/helper'
require 'oauth/client/helper'
require 'oauth/request_proxy/net_http'

class Net::HTTPRequest
  include OAuth::Helper

  attr_reader :oauth_helper

  # Add the OAuth information to an HTTP request. Depending on the <tt>options[:scheme]</tt> setting
  # this may add a header, additional query string parameters, or additional POST body parameters.
  # The default scheme is +header+, in which the OAuth parameters as put into the +Authorization+
  # header.
  #
  # * http - Configured Net::HTTP instance
  # * consumer - OAuth::Consumer instance
  # * token - OAuth::Token instance
  # * options - Request-specific options (e.g. +request_uri+, +consumer+, +token+, +scheme+,
  #   +signature_method+, +nonce+, +timestamp+)
  #
  # This method also modifies the <tt>User-Agent</tt> header to add the OAuth gem version.
  #
  # See Also: {OAuth core spec version 1.0, section 5.4.1}[http://oauth.net/core/1.0#rfc.section.5.4.1],
  #           {OAuth Request Body Hash 1.0 Draft 4}[http://oauth.googlecode.com/svn/spec/ext/body_hash/1.0/drafts/4/spec.html]
  def oauth!(http, consumer = nil, token = nil, options = {})
    helper_options = oauth_helper_options(http, consumer, token, options)
    @oauth_helper = OAuth::Client::Helper.new(self, helper_options)
    @oauth_helper.amend_user_agent_header(self)
    @oauth_helper.hash_body if oauth_body_hash_required?
    self.send("set_oauth_#{helper_options[:scheme]}")
  end

  # Create a string suitable for signing for an HTTP request. This process involves parameter
  # normalization as specified in the OAuth specification. The exact normalization also depends
  # on the <tt>options[:scheme]</tt> being used so this must match what will be used for the request
  # itself. The default scheme is +header+, in which the OAuth parameters as put into the +Authorization+
  # header.
  #
  # * http - Configured Net::HTTP instance
  # * consumer - OAuth::Consumer instance
  # * token - OAuth::Token instance
  # * options - Request-specific options (e.g. +request_uri+, +consumer+, +token+, +scheme+,
  #   +signature_method+, +nonce+, +timestamp+)
  #
  # See Also: {OAuth core spec version 1.0, section 9.1.1}[http://oauth.net/core/1.0#rfc.section.9.1.1],
  #           {OAuth Request Body Hash 1.0 Draft 4}[http://oauth.googlecode.com/svn/spec/ext/body_hash/1.0/drafts/4/spec.html]
  def signature_base_string(http, consumer = nil, token = nil, options = {})
    helper_options = oauth_helper_options(http, consumer, token, options)
    oauth_helper = OAuth::Client::Helper.new(self, helper_options)
    oauth_helper.hash_body if oauth_body_hash_required?
    oauth_helper.signature_base_string
  end

private

  def oauth_helper_options(http, consumer, token, options)
    { :request_uri      => oauth_full_request_uri(http,options),
      :consumer         => consumer,
      :token            => token,
      :scheme           => 'header',
      :signature_method => nil,
      :nonce            => nil,
      :timestamp        => nil }.merge(options)
  end

  def oauth_full_request_uri(http,options)
    uri = URI.parse(self.path)
    uri.host = http.address
    uri.port = http.port

    if options[:request_endpoint] && options[:site]
      uri.host = options[:site].gsub(%r(^https?://), '')
      uri.port = 80
    end

    if http.respond_to?(:use_ssl?) && http.use_ssl?
      uri.scheme = "https"
    else
      uri.scheme = "http"
    end

    uri.to_s
  end

  def oauth_body_hash_required?
    request_body_permitted? && content_type != "application/x-www-form-urlencoded"
  end

  def set_oauth_header
    self['Authorization'] = @oauth_helper.header
  end

  # FIXME: if you're using a POST body and query string parameters, this method
  # will move query string parameters into the body unexpectedly. This may
  # cause problems with non-x-www-form-urlencoded bodies submitted to URLs
  # containing query string params. If duplicate parameters are present in both
  # places, all instances should be included when calculating the signature
  # base string.

  def set_oauth_body
    self.set_form_data(@oauth_helper.stringify_keys(@oauth_helper.parameters_with_oauth))
    params_with_sig = @oauth_helper.parameters.merge(:oauth_signature => @oauth_helper.signature)
    self.set_form_data(@oauth_helper.stringify_keys(params_with_sig))
  end

  def set_oauth_query_string
    oauth_params_str = @oauth_helper.oauth_parameters.map { |k,v| [escape(k), escape(v)] * "=" }.join("&")
    uri = URI.parse(path)
    if uri.query.to_s == ""
      uri.query = oauth_params_str
    else
      uri.query = uri.query + "&" + oauth_params_str
    end

    @path = uri.to_s

    @path << "&oauth_signature=#{escape(oauth_helper.signature)}"
  end
end
