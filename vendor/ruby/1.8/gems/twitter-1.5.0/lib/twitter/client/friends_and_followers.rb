module Twitter
  class Client
    # Defines methods related to friends and followers
    module FriendsAndFollowers
      # @overload friend_ids(options={})
      #   Returns an array of numeric IDs for every user the authenticated user is following
      #
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. This is recommended for users who are following many users. Provide a value of -1 to begin paging. Provide values as returned in the response body's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @return [Array] Numeric IDs.
      #   @example Return the authenticated user's friends' IDs
      #     Twitter.friend_ids
      # @overload friend_ids(user, options={})
      #   Returns an array of numeric IDs for every user the specified user is following
      #
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @return [Array] Numeric IDs.
      #   @example Return @sferik's friends' IDs
      #     Twitter.friend_ids("sferik")
      #     Twitter.friend_ids(7505382)  # Same as above
      # @see http://dev.twitter.com/doc/get/friends/ids
      # @format :json, :xml
      # @authenticated false unless requesting it from a protected user
      #
      #   If getting this data of a protected user, you must authenticate (and be allowed to see that user).
      # @rate_limited true
      def friend_ids(*args)
        options = {:cursor => -1}
        options.merge!(args.last.is_a?(Hash) ? args.pop : {})
        user = args.first
        merge_user_into_options!(user, options)
        response = get('friends/ids', options)
        format.to_s.downcase == 'xml' ? Hashie::Rash.new(:ids => response['id_list']['ids']['id'].map{|id| id.to_i}) : response
      end

      # @overload follower_ids(options={})
      #   Returns an array of numeric IDs for every user following the authenticated user
      #
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @return [Array] Numeric IDs.
      #   @example Return the authenticated user's followers' IDs
      #     Twitter.follower_ids
      # @overload follower_ids(user, options={})
      #   Returns an array of numeric IDs for every user following the specified user
      #
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. This is recommended for users who are following many users. Provide a value of -1 to begin paging. Provide values as returned in the response body's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @return [Array] Numeric IDs.
      #   @example Return @sferik's followers' IDs
      #     Twitter.follower_ids("sferik")
      #     Twitter.follower_ids(7505382)  # Same as above
      # @see http://dev.twitter.com/doc/get/followers/ids
      # @format :json, :xml
      # @authenticated false unless requesting it from a protected user
      #
      #   If getting this data of a protected user, you must authenticate (and be allowed to see that user).
      # @rate_limited true
      def follower_ids(*args)
        options = {:cursor => -1}
        options.merge!(args.last.is_a?(Hash) ? args.pop : {})
        user = args.first
        merge_user_into_options!(user, options)
        response = get('followers/ids', options)
        format.to_s.downcase == 'xml' ? Hashie::Rash.new(:ids => response['id_list']['ids']['id'].map{|id| id.to_i}) : response
      end
    end
  end
end
