module Twitter
  class Client
    # Defines methods related to saved searches
    module SavedSearches
      # Returns the authenticated user's saved search queries
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @return [Array] Saved search queries.
      # @see http://dev.twitter.com/doc/get/saved_searches
      # @example Return the authenticated user's saved search queries
      #   Twitter.saved_searched
      def saved_searches(options={})
        response = get('saved_searches', options)
        format.to_s.downcase == 'xml' ? response['saved_searches'] : response
      end

      # Retrieve the data for a saved search owned by the authenticating user specified by the given ID
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited true
      # @param id [Integer] The ID of the saved search.
      # @param options [Hash] A customizable set of options.
      # @return [Hashie::Rash] The saved search.
      # @see http://dev.twitter.com/doc/get/saved_searches/show/:id
      # @example Retrieve the data for a saved search owned by the authenticating user with the ID 16129012
      #   Twitter.saved_search(16129012)
      def saved_search(id, options={})
        response = get("saved_searches/show/#{id}", options)
        format.to_s.downcase == 'xml' ? response['saved_search'] : response
      end

      # Creates a saved search for the authenticated user
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @param query [String] The query of the search the user would like to save.
      # @param options [Hash] A customizable set of options.
      # @return [Hashie::Rash] The created saved search.
      # @see http://dev.twitter.com/doc/post/saved_searches/create
      # @example Create a saved search for the authenticated user with the query "twitter"
      #   Twitter.saved_search_create("twitter")
      def saved_search_create(query, options={})
        response = post('saved_searches/create', options.merge(:query => query))
        format.to_s.downcase == 'xml' ? response['saved_search'] : response
      end

      # Destroys a saved search for the authenticated user
      # @note The search specified by ID must be owned by the authenticating user.
      #
      # @format :json, :xml
      # @authenticated true
      # @rate_limited false
      # @param id [Integer] The ID of the saved search.
      # @param options [Hash] A customizable set of options.
      # @return [Hashie::Rash] The deleted saved search.
      # @see http://dev.twitter.com/doc/post/saved_searches/destroy/:id
      # @example Destroys a saved search for the authenticated user with the ID 16129012
      #   Twitter.saved_search_destroy(16129012)
      def saved_search_destroy(id, options={})
        response = delete("saved_searches/destroy/#{id}", options)
        format.to_s.downcase == 'xml' ? response['saved_search'] : response
      end
    end
  end
end
