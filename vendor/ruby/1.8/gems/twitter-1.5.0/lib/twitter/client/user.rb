module Twitter
  class Client
    # Defines methods related to users
    module User
      # Returns extended information of a given user
      #
      # @overload user(user, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      #   @return [Hashie::Rash] The requested user.
      #   @example Return extended information for @sferik
      #     Twitter.user("sferik")
      #     Twitter.user(7505382)  # Same as above
      # @format :json, :xml
      # @authenticated false
      # @rate_limited true
      # @see http://dev.twitter.com/doc/get/users/show
      def user(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        user = args.first || get_screen_name
        merge_user_into_options!(user, options)
        response = get('users/show', options)
        format.to_s.downcase == 'xml' ? response['user'] : response
      end

      # Returns extended information for up to 100 users
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @overload users(*users, options={})
      #   @param users [Integer, String] Twitter users ID or screen names.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Array] The requested users.
      # @see http://dev.twitter.com/doc/get/users/lookup
      # @example Return extended information for @sferik and @pengwynn
      #   Twitter.users("sferik", "pengwynn")
      #   Twitter.users("sferik", 14100886)   # Same as above
      #   Twitter.users(7505382, 14100886)    # Same as above
      def users(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        users = args
        merge_users_into_options!(Array(users), options)
        response = get('users/lookup', options)
        format.to_s.downcase == 'xml' ? response['users'] : response
      end

      # Returns users that match the given query
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @param query [String] The search query to run against people search.
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :per_page The number of people to retrieve. Maxiumum of 20 allowed per page.
      # @option options [Integer] :page Specifies the page of results to retrieve.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/users/search
      # @example Return users that match "Erik Michaels-Ober"
      #   Twitter.user_search("Erik Michaels-Ober")
      def user_search(query, options={})
        response = get('users/search', options.merge(:q => query))
        format.to_s.downcase == 'xml' ? response['users'] : response
      end

      # @overload suggestions(options={})
      #   Returns the list of suggested user categories
      #
      #   @param options [Hash] A customizable set of options.
      #   @return [Array]
      #   @see http://dev.twitter.com/doc/get/users/suggestions
      #   @example Return the list of suggested user categories
      #     Twitter.suggestions
      # @overload suggestions(slug, options={})
      #   Returns the users in a given category
      #
      #   @param slug [String] The short name of list or a category.
      #   @param options [Hash] A customizable set of options.
      #   @return [Array]
      #   @see http://dev.twitter.com/doc/get/users/suggestions/:slug
      #   @example Return the users in the Art & Design category
      #     Twitter.suggestions("art-design")
      # @format :json, :xml
      # @authenticated false
      # @rate_limited true
      def suggestions(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        slug = args.first
        response = get(['users/suggestions', slug].compact.join('/'), options)
        xml_key = slug ? 'category' : 'suggestions'
        format.to_s.downcase == 'xml' ? response[xml_key] : response
      end

      # Access the profile image in various sizes for the user with the indicated screen name
      #
      # @overload profile_image(screen_name, options={})
      #   @param screen_name [String] The screen name of the user for whom to return results for.
      #   @param options [Hash] A customizable set of options.
      #   @option options [String] :size ('normal') Specifies the size of image to fetch. Valid options include: 'bigger' (73px by 73px), 'normal' (48px by 48px), and 'mini' (24px by 24px).
      #   @example Return the URL for the 24px by 24px version of @sferik's profile image
      #     Twitter.profile_image("sferik", :size => 'mini')
      # @format :json, :xml
      # @authenticated false
      # @rate_limited false
      # @return [String] The URL for the requested user's profile image.
      # @see http://dev.twitter.com/doc/get/users/profile_image/:screen_name
      def profile_image(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        screen_name = args.first || get_screen_name
        get("users/profile_image/#{screen_name}", options, true).headers['location']
      end

      # Returns a user's friends
      #
      # @overload friends(options={})
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      #   @return [Hashie::Rash]
      #   @example Return the authenticated user's friends
      #     Twitter.friends
      # @overload friends(user, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      #   @return [Hashie::Rash]
      #   @example Return @sferik's friends
      #     Twitter.friends("sferik")
      #     Twitter.friends(7505382)  # Same as above
      # @see http://dev.twitter.com/doc/get/statuses/friends
      # @format :json, :xml
      # @authenticated false unless requesting it from a protected user
      #
      #   If getting this data of a protected user, you must authenticate (and be allowed to see that user).
      # @rate_limited true
      def friends(*args)
        options = {:cursor => -1}
        options.merge!(args.last.is_a?(Hash) ? args.pop : {})
        user = args.first
        if user
          merge_user_into_options!(user, options)
          response = get('statuses/friends', options)
        else
          response = get('statuses/friends', options)
        end
        format.to_s.downcase == 'xml' ? response['users_list'] : response
      end

      # Returns a user's followers
      #
      # @overload followers(options={})
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response object's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      #   @return [Hashie::Rash]
      #   @example Return the authenticated user's followers
      #     Twitter.followers
      # @overload followers(user, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      #   @return [Hashie::Rash]
      #   @example Return @sferik's followers
      #     Twitter.followers("sferik")
      #     Twitter.followers(7505382)  # Same as above
      # @see http://dev.twitter.com/doc/get/statuses/followers
      # @format :json, :xml
      # @authenticated false unless requesting it from a protected user
      #
      #   If getting this data of a protected user, you must authenticate (and be allowed to see that user).
      # @rate_limited true
      def followers(*args)
        options = {:cursor => -1}
        options.merge!(args.last.is_a?(Hash) ? args.pop : {})
        user = args.first
        if user
          merge_user_into_options!(user, options)
          response = get('statuses/followers', options)
        else
          response = get('statuses/followers', options)
        end
        format.to_s.downcase == 'xml' ? response['users_list'] : response
      end
    end
  end
end
