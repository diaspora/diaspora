require 'oauth/signature'
require 'oauth/helper'
require 'oauth/request_proxy/base'
require 'base64'

module OAuth::Signature
  class Base
    include OAuth::Helper

    attr_accessor :options
    attr_reader :token_secret, :consumer_secret, :request

    def self.implements(signature_method = nil)
      return @implements if signature_method.nil?
      @implements = signature_method
      OAuth::Signature.available_methods[@implements] = self
    end

    def self.digest_class(digest_class = nil)
      return @digest_class if digest_class.nil?
      @digest_class = digest_class
    end

    def self.digest_klass(digest_klass = nil)
      return @digest_klass if digest_klass.nil?
      @digest_klass = digest_klass
    end

    def self.hash_class(hash_class = nil)
      return @hash_class if hash_class.nil?
      @hash_class = hash_class
    end

    def initialize(request, options = {}, &block)
      raise TypeError unless request.kind_of?(OAuth::RequestProxy::Base)
      @request = request
      @options = options

      ## consumer secret was determined beforehand

      @consumer_secret = options[:consumer].secret if options[:consumer]

      # presence of :consumer_secret option will override any Consumer that's provided
      @consumer_secret = options[:consumer_secret] if options[:consumer_secret]

      ## token secret was determined beforehand

      @token_secret = options[:token].secret if options[:token]

      # presence of :token_secret option will override any Token that's provided
      @token_secret = options[:token_secret] if options[:token_secret]

      # override secrets based on the values returned from the block (if any)
      if block_given?
        # consumer secret and token secret need to be looked up based on pieces of the request
        secrets = yield block.arity == 1 ? request : [token, consumer_key, nonce, request.timestamp]
        if secrets.is_a?(Array) && secrets.size == 2
          @token_secret = secrets[0]
          @consumer_secret = secrets[1]
        end
      end
    end

    def signature
      Base64.encode64(digest).chomp.gsub(/\n/,'')
    end

    def ==(cmp_signature)
      Base64.decode64(signature) == Base64.decode64(cmp_signature)
    end

    def verify
      self == self.request.signature
    end

    def signature_base_string
      request.signature_base_string
    end

    def body_hash
      if self.class.hash_class
        Base64.encode64(self.class.hash_class.digest(request.body || '')).chomp.gsub(/\n/,'')
      else
        nil # no body hash algorithm defined, so don't generate one
      end
    end

  private

    def token
      request.token
    end

    def consumer_key
      request.consumer_key
    end

    def nonce
      request.nonce
    end

    def secret
      "#{escape(consumer_secret)}&#{escape(token_secret)}"
    end

    def digest
      self.class.digest_class.digest(signature_base_string)
    end
  end
end
