module Faraday
  class Request::JSON < Request::UrlEncoded
    self.mime_type = 'application/json'.freeze

    class << self
      attr_accessor :adapter
    end

    # loads the JSON encoder either from yajl-ruby or activesupport
    dependency do
      begin
        require 'yajl'
        self.adapter = Yajl::Encoder
      rescue LoadError, NameError
        require 'active_support/core_ext/module/attribute_accessors' # AS 2.3.11
        require 'active_support/core_ext/kernel/reporting'           # AS 2.3.11
        require 'active_support/json/encoding'
        require 'active_support/ordered_hash' # AS 3.0.4
        self.adapter = ActiveSupport::JSON
      end
    end

    def call(env)
      match_content_type(env) do |data|
        # encode with the first successfully loaded adapter
        env[:body] = self.class.adapter.encode data
      end
      @app.call env
    end
  end
end
