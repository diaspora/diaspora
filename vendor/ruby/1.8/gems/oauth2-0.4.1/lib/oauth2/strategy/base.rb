module OAuth2
  module Strategy
    class Base #:nodoc:
      def initialize(client)#:nodoc:
        @client = client
      end

      def authorize_url(options={}) #:nodoc:
        @client.authorize_url(authorize_params(options))
      end

      def authorize_params(options={}) #:nodoc:
        options = options.inject({}){|h, (k, v)| h[k.to_s] = v; h}
        {'client_id' => @client.id}.merge(options)
      end

      def access_token_url(options={})
        @client.access_token_url(access_token_params(options))
      end

      def access_token_params(options={})
        return default_params(options)
      end

      def refresh_token_params(options={})
        return default_params(options)
      end

      private
      def default_params(options={})
        {
          'client_id' => @client.id,
          'client_secret' => @client.secret
        }.merge(options)
      end
    end
  end
end
