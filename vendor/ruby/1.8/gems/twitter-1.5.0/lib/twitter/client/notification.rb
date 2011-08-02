module Twitter
  class Client
    # Defines methods related to notification
    module Notification
      # Enables device notifications for updates from the specified user to the authenticating user
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @param user [Integer, String] A Twitter user ID or screen name.
      # @param options [Hash] A customizable set of options.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Hashie::Rash] The specified user.
      # @see http://dev.twitter.com/doc/post/notifications/follow
      # @example Enable device notifications for updates from @sferik
      #   Twitter.enable_notifications("sferik")
      #   Twitter.enable_notifications(7505382)  # Same as above
      def enable_notifications(user, options={})
        merge_user_into_options!(user, options)
        response = post('notifications/follow', options)
        format.to_s.downcase == 'xml' ? response['user'] : response
      end

      # Disables notifications for updates from the specified user to the authenticating user
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @param user [Integer, String] A Twitter user ID or screen name.
      # @param options [Hash] A customizable set of options.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Hashie::Rash] The specified user.
      # @see http://dev.twitter.com/doc/post/notifications/leave
      # @example Disable device notifications for updates from @sferik
      #   Twitter.disable_notifications("sferik")
      #   Twitter.disable_notifications(7505382)  # Same as above
      def disable_notifications(user, options={})
        merge_user_into_options!(user, options)
        response = post('notifications/leave', options)
        format.to_s.downcase == 'xml' ? response['user'] : response
      end
    end
  end
end
