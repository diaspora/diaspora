module Twitter
  class Client
    # Defines methods related to blocking and unblocking users
    # @see Twitter::Client::SpamReporting
    module Block
      # Blocks the user specified by the authenticating user
      #
      # @note Destroys a friendship to the blocked user if it exists.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @param user [Integer, String] A Twitter user ID or screen name.
      # @param options [Hash] A customizable set of options.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Hashie::Rash] The blocked user.
      # @see http://dev.twitter.com/doc/post/blocks/create
      # @example Block and unfriend @sferik as the authenticating user
      #   Twitter.block("sferik")
      #   Twitter.block(7505382)  # Same as above
      def block(user, options={})
        merge_user_into_options!(user, options)
        response = post('blocks/create', options)
        format.to_s.downcase == 'xml' ? response['user'] : response
      end

      # Un-blocks the user specified by the authenticating user
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @param user [Integer, String] A Twitter user ID or screen name.
      # @param options [Hash] A customizable set of options.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Hashie::Rash] The un-blocked user.
      # @see http://dev.twitter.com/doc/post/blocks/destroy
      # @example Un-block @sferik as the authenticating user
      #   Twitter.unblock("sferik")
      #   Twitter.unblock(7505382)  # Same as above
      def unblock(user, options={})
        merge_user_into_options!(user, options)
        response = delete('blocks/destroy', options)
        format.to_s.downcase == 'xml' ? response['user'] : response
      end

      # Returns true if the authenticating user is blocking a target user
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @param user [Integer, String] A Twitter user ID or screen name.
      # @param options [Hash] A customizable set of options.
      # @return [Boolean] true if the authenticating user is blocking the target user, otherwise false.
      # @see http://dev.twitter.com/doc/get/blocks/exists
      # @example Check whether the authenticating user is blocking @sferik
      #   Twitter.block_exists?("sferik")
      #   Twitter.block_exists?(7505382)  # Same as above
      def block_exists?(user, options={})
        merge_user_into_options!(user, options)
        begin
          get('blocks/exists', options)
          true
        rescue Twitter::NotFound
          false
        end
      end

      # Returns an array of user objects that the authenticating user is blocking
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :page Specifies the page of results to retrieve.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Array] User objects that the authenticating user is blocking.
      # @see http://dev.twitter.com/doc/get/blocks/blocking
      # @example Return an array of user objects that the authenticating user is blocking
      #   Twitter.blocking
      def blocking(options={})
        response = get('blocks/blocking', options)
        format.to_s.downcase == 'xml' ? response['users'] : response
      end

      # Returns an array of numeric user ids the authenticating user is blocking
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @return [Array] Numeric user ids the authenticating user is blocking.
      # @see http://dev.twitter.com/doc/get/blocks/blocking/ids
      # @example Return an array of numeric user ids the authenticating user is blocking
      #   Twitter.blocking_ids
      def blocked_ids(options={})
        response = get('blocks/blocking/ids', options)
        format.to_s.downcase == 'xml' ? response['ids']['id'].map{|id| id.to_i} : response
      end
    end
  end
end
