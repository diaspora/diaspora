module Twitter
  class Client
    # Defines methods related to lists
    # @see Twitter::Client::ListMembers
    # @see Twitter::Client::ListSubscribers
    module List
      # Creates a new list for the authenticated user
      #
      # @note Accounts are limited to 20 lists.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @param name [String] The name for the list.
      # @param options [Hash] A customizable set of options.
      # @option options [String] :mode ('public') Whether your list is public or private. Values can be 'public' or 'private'.
      # @option options [String] :description The description to give the list.
      # @return [Hashie::Rash] The created list.
      # @see http://dev.twitter.com/doc/post/:user/lists
      # @example Create a list named "presidents"
      #   Twitter.list_create("presidents")
      def list_create(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        name = args.pop
        if screen_name = args.pop
          warn "#{Kernel.caller.first}: [DEPRECATION] Calling Twitter::Client#list_create with a screen_name is deprecated and will be removed in the next major version. Please omit the screen_name argument."
        end
        response = post("lists/create", options.merge(:name => name))
        format.to_s.downcase == 'xml' ? response['list'] : response
      end

      # Updates the specified list
      #
      # @overload list_update(list, options={})
      #   @param list [Integer, String] The list_id or slug for the list.
      #   @param options [Hash] A customizable set of options.
      #   @option options [String] :mode ('public') Whether your list is public or private. Values can be 'public' or 'private'.
      #   @option options [String] :description The description to give the list.
      #   @return [Hashie::Rash] The created list.
      #   @example Update the authenticated user's "presidents" list to have the description "Presidents of the United States of America"
      #     Twitter.list_update("presidents", :description => "Presidents of the United States of America")
      #     Twitter.list_update(8863586, :description => "Presidents of the United States of America")
      # @overload list_update(user, list, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param list [Integer, String] The list_id or slug for the list.
      #   @param options [Hash] A customizable set of options.
      #   @option options [String] :mode ('public') Whether your list is public or private. Values can be 'public' or 'private'.
      #   @option options [String] :description The description to give the list.
      #   @return [Hashie::Rash] The created list.
      #   @example Update the @sferik's "presidents" list to have the description "Presidents of the United States of America"
      #     Twitter.list_update("sferik", "presidents", :description => "Presidents of the United States of America")
      #     Twitter.list_update(7505382, "presidents", :description => "Presidents of the United States of America")
      #     Twitter.list_update("sferik", 8863586, :description => "Presidents of the United States of America")
      #     Twitter.list_update(7505382, 8863586, :description => "Presidents of the United States of America")
      # @return [Hashie::Rash] The created list.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @see http://dev.twitter.com/doc/post/:user/lists/:id
      def list_update(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        list = args.pop
        user = args.pop || get_screen_name
        merge_list_into_options!(list, options)
        merge_owner_into_options!(user, options)
        response = post("lists/update", options)
        format.to_s.downcase == 'xml' ? response['list'] : response
      end

      # List the lists of the specified user
      #
      # @note Private lists will be included if the authenticated user is the same as the user whose lists are being returned.
      # @overload lists(options={})
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @return [Hashie::Rash]
      #   @example List the authenticated user's lists
      #     Twitter.lists
      # @overload lists(user, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @return [Hashie::Rash]
      #   @example List @sferik's lists
      #     Twitter.lists("sferik")
      #     Twitter.lists(7505382)
      # @return [Hashie::Rash]
      # @see http://dev.twitter.com/doc/get/:user/lists
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      def lists(*args)
        options = {:cursor => -1}.merge(args.last.is_a?(Hash) ? args.pop : {})
        user = args.first
        merge_user_into_options!(user, options) if user
        response = get("lists", options)
        format.to_s.downcase == 'xml' ? response['lists_list'] : response
      end

      # Show the specified list
      #
      # @overload list(list, options={})
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param options [Hash] A customizable set of options.
      #   @return [Hashie::Rash] The specified list.
      #   @example Show the authenticated user's "presidents" list
      #     Twitter.list("presidents")
      #     Twitter.list(8863586)
      # @overload list(user, list, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param options [Hash] A customizable set of options.
      #   @return [Hashie::Rash] The specified list.
      #   @example Show @sferik's "presidents" list
      #     Twitter.list("sferik", "presidents")
      #     Twitter.list("sferik", 8863586)
      #     Twitter.list(7505382, "presidents")
      #     Twitter.list(7505382, 8863586)
      # @return [Hashie::Rash] The specified list.
      # @note Private lists will only be shown if the authenticated user owns the specified list.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @see http://dev.twitter.com/doc/get/:user/lists/:id
      def list(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        list = args.pop
        user = args.pop || get_screen_name
        merge_list_into_options!(list, options)
        merge_owner_into_options!(user, options)
        response = get("lists/show", options)
        format.to_s.downcase == 'xml' ? response['list'] : response
      end

      # Deletes the specified list
      #
      # @overload list_delete(list, options={})
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param options [Hash] A customizable set of options.
      #   @return [Hashie::Rash] The deleted list.
      #   @example Delete the authenticated user's "presidents" list
      #     Twitter.list_delete("presidents")
      #     Twitter.list_delete(8863586)
      # @overload list_delete(user, list, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param options [Hash] A customizable set of options.
      #   @return [Hashie::Rash] The deleted list.
      #   @example Delete @sferik's "presidents" list
      #     Twitter.list_delete("sferik", "presidents")
      #     Twitter.list_delete("sferik", 8863586)
      #     Twitter.list_delete(7505382, "presidents")
      #     Twitter.list_delete(7505382, 8863586)
      # @return [Hashie::Rash] The deleted list.
      # @note Must be owned by the authenticated user.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @see http://dev.twitter.com/doc/delete/:user/lists/:id
      def list_delete(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        list = args.pop
        user = args.pop || get_screen_name
        merge_list_into_options!(list, options)
        merge_owner_into_options!(user, options)
        response = delete("lists/destroy", options)
        format.to_s.downcase == 'xml' ? response['list'] : response
      end

      # Show tweet timeline for members of the specified list
      #
      # @overload list_timeline(list, options={})
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
      #   @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
      #   @option options [Integer] :per_page The number of results to retrieve.
      #   @option options [Integer] :page Specifies the page of results to retrieve.
      #   @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      #   @return [Array]
      #   @example Show tweet timeline for members of the authenticated user's "presidents" list
      #     Twitter.list_timeline("presidents")
      #     Twitter.list_timeline(8863586)
      # @overload list_timeline(user, list, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param list [Integer, String] The list_id or slug of the list.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
      #   @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
      #   @option options [Integer] :per_page The number of results to retrieve.
      #   @option options [Integer] :page Specifies the page of results to retrieve.
      #   @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      #   @return [Array]
      #   @example Show tweet timeline for members of @sferik's "presidents" list
      #     Twitter.list_timeline("sferik", "presidents")
      #     Twitter.list_timeline("sferik", 8863586)
      #     Twitter.list_timeline(7505382, "presidents")
      #     Twitter.list_timeline(7505382, 8863586)
      # @return [Array]
      # @format :json, :xml
      # @authenticated false
      # @rate_limited true
      # @see http://dev.twitter.com/doc/get/:user/lists/:id/statuses
      def list_timeline(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        list = args.pop
        user = args.pop || get_screen_name
        merge_list_into_options!(list, options)
        merge_owner_into_options!(user, options)
        response = get("lists/statuses", options)
        format.to_s.downcase == 'xml' ? response['statuses'] : response
      end

      # List the lists the specified user has been added to
      #
      # @overload memberships(options={})
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @return [Array]
      #   @example List the lists the authenticated user has been added to
      #     Twitter.memberships
      # @overload memberships(user, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @return [Array]
      #   @example List the lists that @sferik has been added to
      #     Twitter.memberships("sferik")
      #     Twitter.memberships(7505382)
      # @return [Array]
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @see http://dev.twitter.com/doc/get/:user/lists/memberships
      def memberships(*args)
        options = {:cursor => -1}.merge(args.last.is_a?(Hash) ? args.pop : {})
        user = args.pop || get_screen_name
        merge_user_into_options!(user, options)
        response = get("lists/memberships", options)
        format.to_s.downcase == 'xml' ? response['lists_list'] : response
      end

      # List the lists the specified user follows
      #
      # @overload subscriptions(options={})
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @return [Array]
      #   @example List the lists the authenticated user follows
      #     Twitter.subscriptions
      # @overload subscriptions(user, options={})
      #   @param user [Integer, String] A Twitter user ID or screen name.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :cursor (-1) Breaks the results into pages. Provide values as returned in the response objects's next_cursor and previous_cursor attributes to page back and forth in the list.
      #   @return [Array]
      #   @example List the lists that @sferik follows
      #     Twitter.subscriptions("sferik")
      #     Twitter.subscriptions(7505382)
      # @return [Array]
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @see http://dev.twitter.com/doc/get/:user/lists/subscriptions
      def subscriptions(*args)
        options = {:cursor => -1}.merge(args.last.is_a?(Hash) ? args.pop : {})
        user = args.pop || get_screen_name
        merge_user_into_options!(user, options)
        response = get("lists/subscriptions", options)
        format.to_s.downcase == 'xml' ? response['lists_list'] : response
      end
    end
  end
end
