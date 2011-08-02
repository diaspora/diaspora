module Twitter
  class Client
    # Defines methods related to friendship
    module Friendship
      # Allows the authenticating user to follow the specified user
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @param user [Integer, String] A Twitter user ID or screen name.
      # @param options [Hash] A customizable set of options.
      # @option options [Boolean] :follow (false) Enable notifications for the target user.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Hashie::Rash] The followed user.
      # @see http://dev.twitter.com/doc/post/friendships/create
      # @example Follow @sferik
      #   Twitter.follow("sferik")
      def follow(user, options={})
        merge_user_into_options!(user, options)
        # Twitter always turns on notifications if the "follow" option is present, even if it's set to false
        # so only send follow if it's true
        options.merge!(:follow => true) if options.delete(:follow)
        response = post('friendships/create', options)
        format.to_s.downcase == 'xml' ? response['user'] : response
      end
      alias :friendship_create :follow

      # Allows the authenticating user to unfollow the specified user
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @param user [Integer, String] A Twitter user ID or screen name.
      # @param options [Hash] A customizable set of options.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Hashie::Rash] The unfollowed user.
      # @see http://dev.twitter.com/doc/post/friendships/destroy
      # @example Unfollow @sferik
      #   Twitter.unfollow("sferik")
      def unfollow(user, options={})
        merge_user_into_options!(user, options)
        response = delete('friendships/destroy', options)
        format.to_s.downcase == 'xml' ? response['user'] : response
      end
      alias :friendship_destroy :unfollow

      # Test for the existence of friendship between two users
      #
      # @note Consider using {Twitter::Client::Friendship#friendship} instead of this method.
      # @format :json, :xml
      # @authenticated false unless user_a or user_b is protected
      # @rate_limited true
      # @param user_a [Integer, String] The ID or screen_name of the subject user.
      # @param user_b [Integer, String] The ID or screen_name of the user to test for following.
      # @param options [Hash] A customizable set of options.
      # @return [Boolean] true if user_a follows user_b, otherwise false.
      # @see http://dev.twitter.com/doc/get/friendships/exists
      # @example Return true if @sferik follows @pengwynn
      #   Twitter.friendship_exists?("sferik", "pengwynn")
      def friendship_exists?(user_a, user_b, options={})
        response = get('friendships/exists', options.merge(:user_a => user_a, :user_b => user_b))
        format.to_s.downcase == 'xml' ? !%w(0 false).include?(response['friends']) : response
      end

      # Returns detailed information about the relationship between two users
      #
      # @format :json, :xml
      # @authenticated false
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :source_id The ID of the subject user.
      # @option options [String] :source_screen_name The screen_name of the subject user.
      # @option options [Integer] :target_id The ID of the target user.
      # @option options [String] :target_screen_name The screen_name of the target user.
      # @return [Hashie::Rash]
      # @see http://dev.twitter.com/doc/get/friendships/show
      # @example Return the relationship between @sferik and @pengwynn
      #   Twitter.friendship(:source_screen_name => "sferik", :target_screen_name => "pengwynn")
      #   Twitter.friendship(:source_id => 7505382, :target_id => 14100886)
      def friendship(options={})
        get('friendships/show', options)['relationship']
      end
      alias :friendship_show :friendship

      # Returns an array of numeric IDs for every user who has a pending request to follow the authenticating user
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      # @return [Hashie::Rash]
      # @see http://dev.twitter.com/doc/get/friendships/incoming
      # @example Return an array of numeric IDs for every user who has a pending request to follow the authenticating user
      #   Twitter.friendships_incoming
      def friendships_incoming(options={})
        options = {:cursor => -1}.merge(options)
        response = get('friendships/incoming', options)
        format.to_s.downcase == 'xml' ? Hashie::Rash.new(:ids => response['id_list']['ids']['id'].map{|id| id.to_i}) : response
      end

      # Returns an array of numeric IDs for every protected user for whom the authenticating user has a pending follow request
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      # @return [Hashie::Rash]
      # @see http://dev.twitter.com/doc/get/friendships/outgoing
      # @example Return an array of numeric IDs for every protected user for whom the authenticating user has a pending follow request
      #   Twitter.friendships_outgoing
      def friendships_outgoing(options={})
        options = {:cursor => -1}.merge(options)
        response = get('friendships/outgoing', options)
        format.to_s.downcase == 'xml' ? Hashie::Rash.new(:ids => response['id_list']['ids']['id'].map{|id| id.to_i}) : response
      end
    end
  end
end
