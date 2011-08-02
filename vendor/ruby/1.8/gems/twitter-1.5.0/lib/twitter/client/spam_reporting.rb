module Twitter
  class Client
    # Defines methods related to spam reporting
    # @see Twitter::Client::Block
    module SpamReporting
      # The user specified is blocked by the authenticated user and reported as a spammer
      #
      # @format :json, :xml
      # @authenticated false
      # @rate_limited true
      # @param user [Integer, String] A Twitter user ID or screen name.
      # @param options [Hash] A customizable set of options.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Hashie::Rash] The requested user.
      # @see http://dev.twitter.com/doc/post/report_spam
      # @example Report @spam for spam
      #   Twitter.report_spam("spam")
      #   Twitter.report_spam(14589771) # Same as above
      def report_spam(user, options={})
        merge_user_into_options!(user, options)
        response = post('report_spam', options)
        format.to_s.downcase == 'xml' ? response['user'] : response
      end
    end
  end
end
