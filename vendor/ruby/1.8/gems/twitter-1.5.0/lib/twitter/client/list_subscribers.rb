module Twitter
  class Client
    # Defines methods related to list subscribers
    # @see Twitter::Client::List
    # @see Twitter::Client::ListMembers
    module ListSubscribers
      # Returns the subscribers of the specified list
      #
      # @overload list_subscribers(list, options={})
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      #   @return [Array] The subscribers of the specified list.
      #   @example Return the subscribers of the authenticated user's "presidents" list
      #     Twitter.list_subscribers('presidents')
      #     Twitter.list_subscribers(8863586)
      # @overload list_subscribers(user, list, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      #   @return [Array] The subscribers of the specified list.
      #   @example Return the subscribers of @sferik's "presidents" list
      #     Twitter.list_subscribers("sferik", 'presidents')
      #     Twitter.list_subscribers("sferik", 8863586)
      #     Twitter.list_subscribers(7505382, 'presidents')
      # @return [Array] The subscribers of the specified list.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @see http://dev.twitter.com/doc/get/:user/:list_id/subscribers
      def list_subscribers(*args)
        options = {:cursor => -1}.merge(args.last.is_a?(Hash) ? args.pop : {})
        list = args.pop
        user = args.pop || get_screen_name
        merge_list_into_options!(list, options)
        merge_owner_into_options!(user, options)
        response = get("lists/subscribers", options)
        format.to_s.downcase == 'xml' ? response['users_list'] : response
      end

      # Make the authenticated user follow the specified list
      #
      # @overload list_subscribe(list, options={})
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param options [Hash] A customizable set of options.
      #   @return [Hashie::Rash] The specified list.
      #   @example Subscribe to the authenticated user's "presidents" list
      #     Twitter.list_subscribe('presidents')
      #     Twitter.list_subscribe(8863586)
      # @overload list_subscribe(user, list, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param options [Hash] A customizable set of options.
      #   @return [Hashie::Rash] The specified list.
      #   @example Subscribe to @sferik's "presidents" list
      #     Twitter.list_subscribe("sferik", 'presidents')
      #     Twitter.list_subscribe("sferik", 8863586)
      #     Twitter.list_subscribe(7505382, 'presidents')
      # @return [Hashie::Rash] The specified list.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @see http://dev.twitter.com/doc/post/:user/:list_id/subscribers
      def list_subscribe(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        list = args.pop
        user = args.pop || get_screen_name
        merge_list_into_options!(list, options)
        merge_owner_into_options!(user, options)
        response = post("lists/subscribers/create", options)
        format.to_s.downcase == 'xml' ? response['list'] : response
      end

      # Unsubscribes the authenticated user form the specified list
      #
      # @overload list_unsubscribe(list, options={})
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param options [Hash] A customizable set of options.
      #   @return [Hashie::Rash] The specified list.
      #   @example Unsubscribe from the authenticated user's "presidents" list
      #     Twitter.list_unsubscribe('presidents')
      #     Twitter.list_unsubscribe(8863586)
      # @overload list_unsubscribe(user, list, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param options [Hash] A customizable set of options.
      #   @return [Hashie::Rash] The specified list.
      #   @example Unsubscribe from @sferik's "presidents" list
      #     Twitter.list_unsubscribe("sferik", 'presidents')
      #     Twitter.list_unsubscribe("sferik", 8863586)
      #     Twitter.list_unsubscribe(7505382, 'presidents')
      # @return [Hashie::Rash] The specified list.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @see http://dev.twitter.com/doc/delete/:user/:list_id/subscribers
      def list_unsubscribe(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        list = args.pop
        user = args.pop || get_screen_name
        merge_list_into_options!(list, options)
        merge_owner_into_options!(user, options)
        response = post("lists/subscribers/destroy", options)
        format.to_s.downcase == 'xml' ? response['list'] : response
      end

      # Check if a user is a subscriber of the specified list
      #
      # @overload is_subscriber?(list, user_to_check, options={})
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param user_to_check [Integer, String] The user ID or screen_name of the list member.
      #   @param options [Hash] A customizable set of options.
      #   @return [Boolean] true if user is a subscriber of the specified list, otherwise false.
      #   @example Check if @BarackObama is a subscriber of the authenticated user's "presidents" list
      #     Twitter.is_subscriber?('presidents', 813286)
      #     Twitter.is_subscriber?(8863586, 813286)
      #     Twitter.is_subscriber?('presidents', 'BarackObama')
      # @overload is_subscriber?(user, list, user_to_check, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param user_to_check [Integer, String] The user ID or screen_name of the list member.
      #   @param options [Hash] A customizable set of options.
      #   @return [Boolean] true if user is a subscriber of the specified list, otherwise false.
      #   @example Check if @BarackObama is a subscriber of @sferik's "presidents" list
      #     Twitter.is_subscriber?("sferik", 'presidents', 813286)
      #     Twitter.is_subscriber?("sferik", 8863586, 813286)
      #     Twitter.is_subscriber?(7505382, 'presidents', 813286)
      #     Twitter.is_subscriber?("sferik", 'presidents', 'BarackObama')
      # @return [Boolean] true if user is a subscriber of the specified list, otherwise false.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @see http://dev.twitter.com/doc/get/:user/:list_id/subscribers/:id
      def is_subscriber?(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        user_to_check, list = args.pop, args.pop
        user = args.pop || get_screen_name
        merge_list_into_options!(list, options)
        merge_owner_into_options!(user, options)
        merge_user_into_options!(user_to_check, options)
        begin
          get("lists/subscribers/show", options)
          true
        rescue Twitter::NotFound, Twitter::Forbidden
          false
        end
      end
    end
  end
end
