module Twitter
  class Client
    # Defines methods related to legal documents
    module Legal
      # Returns {http://twitter.com/tos Twitter's Terms of Service}
      #
      # @format :json, :xml
      # @authenticated false
      # @rate_limited true
      # @return [String]
      # @see http://dev.twitter.com/doc/get/legal/tos
      # @example Return {http://twitter.com/tos Twitter's Terms of Service}
      #   Twitter.tos
      def tos(options={})
        get('legal/tos', options)['tos']
      end

      # Returns {http://twitter.com/privacy Twitter's Privacy Policy}
      #
      # @format :json, :xml
      # @authenticated false
      # @rate_limited true
      # @return [String]
      # @see http://dev.twitter.com/doc/get/legal/privacy
      # @example Return {http://twitter.com/privacy Twitter's Privacy Policy}
      #   Twitter.privacy
      def privacy(options={})
        get('legal/privacy', options)['privacy']
      end
    end
  end
end
