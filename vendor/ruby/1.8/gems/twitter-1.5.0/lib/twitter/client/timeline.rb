module Twitter
  class Client
    # Defines methods related to timelines
    module Timeline
      # Returns the 20 most recent statuses, including retweets if they exist, from non-protected users
      #
      # @note The public timeline is cached for 60 seconds. Requesting more frequently than that will not return any more data, and will count against your rate limit usage.
      # @format :json, :xml
      # @authenticated false
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/statuses/public_timeline
      # @example Return the 20 most recent statuses, including retweets if they exist, from non-protected users
      #   Twitter.public_timeline
      def public_timeline(options={})
        response = get('statuses/public_timeline', options)
        format.to_s.downcase == 'xml' ? response['statuses'] : response
      end

      # Returns the 20 most recent statuses, including retweets if they exist, posted by the authenticating user and the users they follow
      #
      # @note This method is identical to {Twitter::Client::Timeline#friends_timeline}, except that this method always includes retweets.
      # @note This method can only return up to 800 statuses, including retweets.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
      # @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
      # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
      # @option options [Integer] :page Specifies the page of results to retrieve.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/statuses/home_timeline
      # @example Return the 20 most recent statuses, including retweets if they exist, posted by the authenticating user and the users they follow
      #   Twitter.home_timeline
      def home_timeline(options={})
        response = get('statuses/home_timeline', options)
        format.to_s.downcase == 'xml' ? response['statuses'] : response
      end

      # Returns the 20 most recent statuses posted by the authenticating user and the users they follow
      #
      # @note This method is identical to {Twitter::Client::Timeline#home_timeline}, except that this method will only include retweets if the :include_rts option is set.
      # @note This method can only return up to 800 statuses. If the :include_rts option is set, only 800 statuses, including retweets if they exist, can be returned.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
      # @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
      # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
      # @option options [Integer] :page Specifies the page of results to retrieve.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :include_rts The timeline will contain native retweets (if they exist) in addition to the standard stream of tweets when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/statuses/friends_timeline
      # @example Return the 20 most recent statuses, including retweets if they exist, posted by the authenticating user and the users they follow
      #   Twitter.friends_timeline
      def friends_timeline(options={})
        response = get('statuses/friends_timeline', options)
        format.to_s.downcase == 'xml' ? response['statuses'] : response
      end

      # Returns the 20 most recent statuses posted by the specified user
      #
      # @overload user_timeline(user, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
      #   @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
      #   @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
      #   @option options [Integer] :page Specifies the page of results to retrieve.
      #   @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      #   @option options [Boolean, String, Integer] :include_rts The timeline will contain native retweets (if they exist) in addition to the standard stream of tweets when set to true, 't' or 1.
      #   @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      #   @return [Array]
      #   @example Return the 20 most recent statuses posted by @sferik
      #     Twitter.user_timeline("sferik")
      # @note This method can only return up to 3200 statuses. If the :include_rts option is set, only 3200 statuses, including retweets if they exist, can be returned.
      # @format :json, :xml
      # @authenticated false unless the user whose timeline you're trying to view is protected
      # @rate_limited true
      # @see http://dev.twitter.com/doc/get/statuses/user_timeline
      def user_timeline(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        user = args.first || get_screen_name
        merge_user_into_options!(user, options)
        response = get('statuses/user_timeline', options)
        format.to_s.downcase == 'xml' ? response['statuses'] : response
      end

      # Returns the 20 most recent mentions (statuses containing @username) for the authenticating user
      #
      # @note This method can only return up to 800 statuses. If the :include_rts option is set, only 800 statuses, including retweets if they exist, can be returned.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
      # @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
      # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
      # @option options [Integer] :page Specifies the page of results to retrieve.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :include_rts The timeline will contain native retweets (if they exist) in addition to the standard stream of tweets when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/statuses/mentions
      # @example Return the 20 most recent mentions (statuses containing @username) for the authenticating user
      #   Twitter.mentions
      def mentions(options={})
        response = get('statuses/mentions', options)
        format.to_s.downcase == 'xml' ? response['statuses'] : response
      end

      # Returns the 20 most recent retweets posted by the authenticating user
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
      # @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
      # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
      # @option options [Integer] :page Specifies the page of results to retrieve.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/statuses/retweeted_by_me
      # @example Return the 20 most recent retweets posted by the authenticating user
      #   Twitter.retweeted_by_me
      def retweeted_by_me(options={})
        response = get('statuses/retweeted_by_me', options)
        format.to_s.downcase == 'xml' ? response['statuses'] : response
      end

      # Returns the 20 most recent retweets posted by users followed by the authenticating user
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
      # @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
      # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
      # @option options [Integer] :page Specifies the page of results to retrieve.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/statuses/retweeted_to_me
      # @example Return the 20 most recent retweets posted by users followed by the authenticating user
      #   Twitter.retweeted_to_me
      def retweeted_to_me(options={})
        response = get('statuses/retweeted_to_me', options)
        format.to_s.downcase == 'xml' ? response['statuses'] : response
      end

      # Returns the 20 most recent tweets of the authenticated user that have been retweeted by others
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
      # @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
      # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
      # @option options [Integer] :page Specifies the page of results to retrieve.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/statuses/retweets_of_me
      # @example Return the 20 most recent tweets of the authenticated user that have been retweeted by others
      #   Twitter.retweets_of_me
      def retweets_of_me(options={})
        response = get('statuses/retweets_of_me', options)
        format.to_s.downcase == 'xml' ? response['statuses'] : response
      end
    end
  end
end
