module Twitter
  class Client
    # Defines methods related to list members
    # @see Twitter::Client::List
    # @see Twitter::Client::ListSubscribers
    module ListMembers
      # Returns the members of the specified list
      #
      # @overload list_members(list, options={})
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      #   @return [Array]
      #   @example Return the members of the authenticated user's "presidents" list
      #     Twitter.list_members("presidents")
      #     Twitter.list_members(8863586)
      # @overload list_members(user, list, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      #   @return [Array]
      #   @example Return the members of @sferik's "presidents" list
      #     Twitter.list_members("sferik", "presidents")
      #     Twitter.list_members("sferik", 8863586)
      #     Twitter.list_members(7505382, "presidents")
      #     Twitter.list_members(7505382, 8863586)
      # @return [Array]
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @see http://dev.twitter.com/doc/get/:user/:list_id/members
      def list_members(*args)
        options = {:cursor => -1}.merge(args.last.is_a?(Hash) ? args.pop : {})
        list = args.pop
        user = args.pop || get_screen_name
        merge_list_into_options!(list, options)
        merge_owner_into_options!(user, options)
        response = get("lists/members", options)
        format.to_s.downcase == 'xml' ? response['users_list'] : response
      end

      # Add a member to a list
      #
      # @overload list_add_member(list, user_to_add, options={})
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param user_to_add [Integer, String] The user id or screen name to add to the list.
      #   @param options [Hash] A customizable set of options.
      #   @return [Hashie::Rash] The list.
      #   @example Add @BarackObama to the authenticated user's "presidents" list
      #     Twitter.list_add_member("presidents", 813286)
      #     Twitter.list_add_member(8863586, 813286)
      # @overload list_add_member(user, list, user_to_add, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param user_to_add [Integer, String] The user id or screen name to add to the list.
      #   @param options [Hash] A customizable set of options.
      #   @return [Hashie::Rash] The list.
      #   @example Add @BarackObama to @sferik's "presidents" list
      #     Twitter.list_add_member("sferik", "presidents", 813286)
      #     Twitter.list_add_member('sferik', 8863586, 813286)
      #     Twitter.list_add_member(7505382, "presidents", 813286)
      #     Twitter.list_add_member(7505382, 8863586, 813286)
      # @return [Hashie::Rash] The list.
      # @note Lists are limited to having 500 members.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @see http://dev.twitter.com/doc/post/:user/:list_id/members
      def list_add_member(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        user_to_add, list = args.pop, args.pop
        user = args.pop || get_screen_name
        merge_list_into_options!(list, options)
        merge_owner_into_options!(user, options)
        merge_user_into_options!(user_to_add, options)
        response = post("lists/members/create", options)
        format.to_s.downcase == 'xml' ? response['list'] : response
      end

      # Adds multiple members to a list
      #
      # @overload list_add_members(list, users_to_add, options={})
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param users_to_add [Array] The user IDs and/or screen names to add.
      #   @param options [Hash] A customizable set of options.
      #   @return [Hashie::Rash] The list.
      #   @example Add @BarackObama and @pengwynn to the authenticated user's "presidents" list
      #     Twitter.list_add_members("presidents", [813286, 18755393])
      #     Twitter.list_add_members('presidents', [813286, 'pengwynn'])
      #     Twitter.list_add_members(8863586, [813286, 18755393])
      # @overload list_add_members(user, list, users_to_add, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param users_to_add [Array] The user IDs and/or screen names to add.
      #   @param options [Hash] A customizable set of options.
      #   @return [Hashie::Rash] The list.
      #   @example Add @BarackObama and @pengwynn to @sferik's "presidents" list
      #     Twitter.list_add_members("sferik", "presidents", [813286, 18755393])
      #     Twitter.list_add_members('sferik', 'presidents', [813286, 'pengwynn'])
      #     Twitter.list_add_members('sferik', 8863586, [813286, 18755393])
      #     Twitter.list_add_members(7505382, "presidents", [813286, 18755393])
      #     Twitter.list_add_members(7505382, 8863586, [813286, 18755393])
      # @return [Hashie::Rash] The list.
      # @note Lists are limited to having 500 members, and you are limited to adding up to 100 members to a list at a time with this method.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @see http://dev.twitter.com/doc/post/:user/:list_id/create_all
      def list_add_members(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        users_to_add, list = args.pop, args.pop
        user = args.pop || get_screen_name
        merge_list_into_options!(list, options)
        merge_owner_into_options!(user, options)
        merge_users_into_options!(Array(users_to_add), options)
        response = post("lists/members/create_all", options)
        format.to_s.downcase == 'xml' ? response['list'] : response
      end

      # Removes the specified member from the list
      #
      # @overload list_remove_member(list, user_to_remove, options={})
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param user_to_remove [Integer, String] The user id or screen name of the list member to remove.
      #   @param options [Hash] A customizable set of options.
      #   @return [Hashie::Rash] The list.
      #   @example Remove @BarackObama from the authenticated user's "presidents" list
      #     Twitter.list_remove_member("presidents", 813286)
      #     Twitter.list_remove_member("presidents", 'BarackObama')
      #     Twitter.list_remove_member(8863586, 'BarackObama')
      # @overload list_remove_member(user, list, user_to_remove, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param user_to_remove [Integer, String] The user id or screen name of the list member to remove.
      #   @param options [Hash] A customizable set of options.
      #   @return [Hashie::Rash] The list.
      #   @example Remove @BarackObama from @sferik's "presidents" list
      #     Twitter.list_remove_member("sferik", "presidents", 813286)
      #     Twitter.list_remove_member("sferik", "presidents", 'BarackObama')
      #     Twitter.list_remove_member('sferik', 8863586, 'BarackObama')
      #     Twitter.list_remove_member(7505382, "presidents", 813286)
      # @return [Hashie::Rash] The list.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @see http://dev.twitter.com/doc/delete/:user/:list_id/members
      def list_remove_member(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        user_to_remove, list = args.pop, args.pop
        user = args.pop || get_screen_name
        merge_list_into_options!(list, options)
        merge_owner_into_options!(user, options)
        merge_user_into_options!(user_to_remove, options)
        response = post("lists/members/destroy", options)
        format.to_s.downcase == 'xml' ? response['list'] : response
      end

      # Check if a user is a member of the specified list
      #
      # @overload is_list_member?(list, user_to_check, options={})
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param user_to_check [Integer, String] The user ID or screen name of the list member.
      #   @param options [Hash] A customizable set of options.
      #   @return [Boolean] true if user is a member of the specified list, otherwise false.
      #   @example Check if @BarackObama is a member of the authenticated user's "presidents" list
      #     Twitter.is_list_member?("presidents", 813286)
      #     Twitter.is_list_member?(8863586, 'BarackObama')
      # @overload is_list_member?(user, list, user_to_check, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param user_to_check [Integer, String] The user ID or screen name of the list member.
      #   @param options [Hash] A customizable set of options.
      #   @return [Boolean] true if user is a member of the specified list, otherwise false.
      #   @example Check if @BarackObama is a member of @sferik's "presidents" list
      #     Twitter.is_list_member?("sferik", "presidents", 813286)
      #     Twitter.is_list_member?('sferik', 8863586, 'BarackObama')
      #     Twitter.is_list_member?(7505382, "presidents", 813286)
      # @return [Boolean] true if user is a member of the specified list, otherwise false.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @see http://dev.twitter.com/doc/get/:user/:list_id/members/:id
      def is_list_member?(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        user_to_check, list = args.pop, args.pop
        user = args.pop || get_screen_name
        merge_list_into_options!(list, options)
        merge_owner_into_options!(user, options)
        merge_user_into_options!(user_to_check, options)
        puts "Options are #{options.inspect}"
        begin
          get("lists/members/show", options)
          true
        rescue Twitter::NotFound, Twitter::Forbidden
          false
        end
      end
    end
  end
end
