require 'rack'
require 'singleton'
require 'omniauth/form'

module OmniAuth

  autoload :Builder,  'omniauth/builder'
  autoload :Strategy, 'omniauth/strategy'
  autoload :Test,     'omniauth/test'

  module Strategies
    autoload :Password, 'omniauth/strategies/password'
  end

  class Configuration
    include Singleton

    @@defaults = {
      :path_prefix => '/auth',
      :on_failure => Proc.new do |env, message_key|
        new_path = "#{OmniAuth.config.path_prefix}/failure?message=#{message_key}"
        [302, {'Location' => "#{new_path}", 'Content-Type'=> 'text/html'}, []]
      end,
      :form_css => Form::DEFAULT_CSS
    }

    def self.defaults
      @@defaults
    end

    def initialize
      @@defaults.each_pair{|k,v| self.send("#{k}=",v)}
    end

    def on_failure(&block)
      if block_given?
        @on_failure = block
      else
        @on_failure
      end
    end

    attr_writer :on_failure
    attr_accessor :path_prefix, :form_css
  end

  def self.config
    Configuration.instance
  end

  def self.configure
    yield config
  end

  module Utils
    CAMELIZE_SPECIAL = {
      'oauth' => 'OAuth',
      'oauth2' => 'OAuth2',
      'openid' => 'OpenID',
      'open_id' => 'OpenID',
      'github' => 'GitHub',
      'tripit' => 'TripIt',
      'soundcloud' => 'SoundCloud'
    }

    module_function

    def form_css
      "<style type='text/css'>#{OmniAuth.config.form_css}</style>"
    end

    def deep_merge(hash, other_hash)
      target = hash.dup

      other_hash.keys.each do |key|
        if other_hash[key].is_a? ::Hash and hash[key].is_a? ::Hash
          target[key] = deep_merge(target[key],other_hash[key])
          next
        end

        target[key] = other_hash[key]
      end

      target
    end

    def camelize(word, first_letter_in_uppercase = true)
      return CAMELIZE_SPECIAL[word.to_s] if CAMELIZE_SPECIAL[word.to_s]

      if first_letter_in_uppercase
        word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
      else
        word.first + camelize(word)[1..-1]
      end
    end
  end
end
