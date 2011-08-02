module Twitter
  class Client
    # Defines methods related to tweets
    module Tweets
      # Returns a single status, specified by ID
      #
      # @format :json, :xml
      # @authenticated false unless the author of the status is protected
      # @rate_limited true
      # @param id [Integer] The numerical ID of the desired status.
      # @param options [Hash] A customizable set of options.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Hashie::Rash] The requested status.
      # @see http://dev.twitter.com/doc/get/statuses/show/:id
      # @example Return the status with the ID 25938088801
      #   Twitter.status(25938088801)
      def status(id, options={})
        response = get("statuses/show/#{id}", options)
        format.to_s.downcase == 'xml' ? response['status'] : response
      end

      # Updates the authenticating user's status
      #
      # @note A status update with text identical to the authenticating user's current status will be ignored to prevent duplicates.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @param status [String] The text of your status update, up to 140 characters.
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :in_reply_to_status_id The ID of an existing status that the update is in reply to.
      # @option options [Float] :lat The latitude of the location this tweet refers to. This option will be ignored unless it is inside the range -90.0 to +90.0 (North is positive) inclusive. It will also be ignored if there isn't a corresponding :long option.
      # @option options [Float] :long The longitude of the location this tweet refers to. The valid ranges for longitude is -180.0 to +180.0 (East is positive) inclusive. This option will be ignored if outside that range, if it is not a number, if geo_enabled is disabled, or if there not a corresponding :lat option.
      # @option options [String] :place_id A place in the world. These IDs can be retrieved from {Twitter::Client::Geo#reverse_geocode}.
      # @option options [String] :display_coordinates Whether or not to put a pin on the exact coordinates a tweet has been sent from.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Hashie::Rash] The created status.
      # @see http://dev.twitter.com/doc/post/statuses/update
      # @example Update the authenticating user's status
      #   Twitter.update("I just posted a status update via the Twitter Ruby Gem!")
      def update(status, options={})
        response = post('statuses/update', options.merge(:status => status))
        format.to_s.downcase == 'xml' ? response['status'] : response
      end

      # Destroys the specified status
      #
      # @note The authenticating user must be the author of the specified status.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @param id [Integer] The numerical ID of the desired status.
      # @param options [Hash] A customizable set of options.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Hashie::Rash] The deleted status.
      # @see http://dev.twitter.com/doc/post/statuses/destroy/:id
      # @example Destroy the status with the ID 25938088801
      #   Twitter.status_destroy(25938088801)
      def status_destroy(id, options={})
        response = delete("statuses/destroy/#{id}", options)
        format.to_s.downcase == 'xml' ? response['status'] : response
      end

      # Retweets a tweet
      #
      # @note The authenticating user must be the author of the specified status.
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @param id [Integer] The numerical ID of the desired status.
      # @param options [Hash] A customizable set of options.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Hashie::Rash] The original tweet with retweet details embedded.
      # @see http://dev.twitter.com/doc/post/statuses/retweet/:id
      # @example Retweet the status with the ID 28561922516
      #   Twitter.retweet(28561922516)
      def retweet(id, options={})
        response = post("statuses/retweet/#{id}", options)
        format.to_s.downcase == 'xml' ? response['status'] : response
      end

      # Returns up to 100 of the first retweets of a given tweet
      #
      # @format :json, :xml
      # @authenticated false
      # @rate_limited true
      # @param id [Integer] The numerical ID of the desired status.
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 100.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/statuses/retweets/:id
      # @example Return up to 100 of the first retweets of the status with the ID 28561922516
      #   Twitter.retweets(28561922516)
      def retweets(id, options={})
        response = get("statuses/retweets/#{id}", options)
        format.to_s.downcase == 'xml' ? response['statuses'] : response
      end

      # Show up to 100 users who retweeted the status
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @param id [Integer] The numerical ID of the desired status.
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 100.
      # @option options [Integer] :page Specifies the page of results to retrieve.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :include_entities Include {http://dev.twitter.com/pages/tweet_entities Tweet Entities} when set to true, 't' or 1.
      # @option options [Boolean] :ids_only ('false') Only return user ids instead of full user objects.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/statuses/:id/retweeted_by
      # @see http://dev.twitter.com/doc/get/statuses/:id/retweeted_by/ids
      # @example Show up to 100 users who retweeted the status with the ID 28561922516
      #   Twitter.retweeters_of(28561922516)
      def retweeters_of(id, options={})
        ids_only = !!options.delete(:ids_only)
        response = get("statuses/#{id}/retweeted_by#{'/ids' if ids_only}", options)
        format.to_s.downcase == 'xml' ? response['users'] : response
      end
    end
  end
end
