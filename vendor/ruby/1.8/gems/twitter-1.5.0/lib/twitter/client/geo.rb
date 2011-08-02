module Twitter
  class Client
    # Defines methods related to geography
    # @see http://dev.twitter.com/pages/geo_dev_guidelines Twitter Geo Developer Guidelines
    module Geo
      # Search for places that can be attached to a {Twitter::Client::Tweets#update}
      #
      # @format :json
      # @authenticated false
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [Float] :lat The latitude to search around. This option will be ignored unless it is inside the range -90.0 to +90.0 (North is positive) inclusive. It will also be ignored if there isn't a corresponding :long option.
      # @option options [Float] :long The longitude to search around. The valid range for longitude is -180.0 to +180.0 (East is positive) inclusive. This option will be ignored if outside that range, if it is not a number, if geo_enabled is disabled, or if there not a corresponding :lat option.
      # @option options [String] :query Free-form text to match against while executing a geo-based query, best suited for finding nearby locations by name.
      # @option options [String] :ip An IP address. Used when attempting to fix geolocation based off of the user's IP address.
      # @option options [String] :granularity ('neighborhood') This is the minimal granularity of place types to return and must be one of: 'poi', 'neighborhood', 'city', 'admin' or 'country'.
      # @option options [String] :accuracy ('0m') A hint on the "region" in which to search. If a number, then this is a radius in meters, but it can also take a string that is suffixed with ft to specify feet. If coming from a device, in practice, this value is whatever accuracy the device has measuring its location (whether it be coming from a GPS, WiFi triangulation, etc.).
      # @option options [Integer] :max_results A hint as to the number of results to return. This does not guarantee that the number of results returned will equal max_results, but instead informs how many "nearby" results to return. Ideally, only pass in the number of places you intend to display to the user here.
      # @option options [String] :contained_within This is the place_id which you would like to restrict the search results to. Setting this value means only places within the given place_id will be found.
      # @option options [String] :"attribute:street_address" This option searches for places which have this given street address. There are other well-known and application-specific attributes available. Custom attributes are also permitted.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/geo/search
      # @example Return an array of places near the IP address 74.125.19.104
      #   Twitter.places_nearby(:ip => "74.125.19.104")
      def places_nearby(options={})
        get('geo/search', options)['result']['places']
      end
      alias :geo_search :places_nearby

      # Locates places near the given coordinates which are similar in name
      #
      # @note Conceptually, you would use this method to get a list of known places to choose from first. Then, if the desired place doesn't exist, make a request to {Twitter::Client::Geo#place} to create a new one. The token contained in the response is the token necessary to create a new place.
      # @format :json
      # @authenticated false
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [Float] :lat The latitude to search around. This option will be ignored unless it is inside the range -90.0 to +90.0 (North is positive) inclusive. It will also be ignored if there isn't a corresponding :long option.
      # @option options [Float] :long The longitude to search around. The valid range for longitude is -180.0 to +180.0 (East is positive) inclusive. This option will be ignored if outside that range, if it is not a number, if geo_enabled is disabled, or if there not a corresponding :lat option.
      # @option options [String] :name The name a place is known as.
      # @option options [String] :contained_within This is the place_id which you would like to restrict the search results to. Setting this value means only places within the given place_id will be found.
      # @option options [String] :"attribute:street_address" This option searches for places which have this given street address. There are other well-known and application-specific attributes available. Custom attributes are also permitted.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/geo/similar_places
      # @example Return an array of places similar to Twitter HQ
      #   Twitter.places_similar(:lat => "37.7821120598956", :long => "-122.400612831116", :name => "Twitter HQ")
      def places_similar(options={})
        get('geo/similar_places', options)['result']
      end

      # Searches for up to 20 places that can be used as a place_id
      #
      # @note This request is an informative call and will deliver generalized results about geography.
      # @format :json
      # @authenticated false
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [Float] :lat The latitude to search around. This option will be ignored unless it is inside the range -90.0 to +90.0 (North is positive) inclusive. It will also be ignored if there isn't a corresponding :long option.
      # @option options [Float] :long The longitude to search around. The valid range for longitude is -180.0 to +180.0 (East is positive) inclusive. This option will be ignored if outside that range, if it is not a number, if geo_enabled is disabled, or if there not a corresponding :lat option.
      # @option options [String] :accuracy ('0m') A hint on the "region" in which to search. If a number, then this is a radius in meters, but it can also take a string that is suffixed with ft to specify feet. If coming from a device, in practice, this value is whatever accuracy the device has measuring its location (whether it be coming from a GPS, WiFi triangulation, etc.).
      # @option options [String] :granularity ('neighborhood') This is the minimal granularity of place types to return and must be one of: 'poi', 'neighborhood', 'city', 'admin' or 'country'.
      # @option options [Integer] :max_results A hint as to the number of results to return. This does not guarantee that the number of results returned will equal max_results, but instead informs how many "nearby" results to return. Ideally, only pass in the number of places you intend to display to the user here.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/geo/reverse_geocode
      # @example Return an array of places within the specified region
      #   Twitter.reverse_geocode(:lat => "37.7821120598956", :long => "-122.400612831116")
      def reverse_geocode(options={})
        get('geo/reverse_geocode', options)['result']['places']
      end

      # Returns all the information about a known place
      #
      # @format :json
      # @authenticated false
      # @rate_limited true
      # @param place_id [String] A place in the world. These IDs can be retrieved from {Twitter::Client::Geo#reverse_geocode}.
      # @param options [Hash] A customizable set of options.
      # @return [Hashie::Rash] The requested place.
      # @see http://dev.twitter.com/doc/get/geo/id/:place_id
      # @example Return all the information about Twitter HQ
      #   Twitter.place("247f43d441defc03")
      def place(place_id, options={})
        get("geo/id/#{place_id}", options)
      end

      # Creates a new place at the given latitude and longitude
      #
      # @format :json
      # @authenticated false
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [String] :name The name a place is known as.
      # @option options [String] :contained_within This is the place_id which you would like to restrict the search results to. Setting this value means only places within the given place_id will be found.
      # @option options [String] :token The token found in the response from {Twitter::Client::Geo#places_similar}.
      # @option options [Float] :lat The latitude to search around. This option will be ignored unless it is inside the range -90.0 to +90.0 (North is positive) inclusive. It will also be ignored if there isn't a corresponding :long option.
      # @option options [Float] :long The longitude to search around. The valid range for longitude is -180.0 to +180.0 (East is positive) inclusive. This option will be ignored if outside that range, if it is not a number, if geo_enabled is disabled, or if there not a corresponding :lat option.
      # @option options [String] :"attribute:street_address" This option searches for places which have this given street address. There are other well-known and application-specific attributes available. Custom attributes are also permitted.
      # @return [Hashie::Rash] The created place.
      # @see http://dev.twitter.com/doc/post/geo/place
      # @example Create a new place
      #   Twitter.place_create(:name => "@sferik's Apartment", :token => "22ff5b1f7159032cf69218c4d8bb78bc", :contained_within => "41bcb736f84a799e", :lat => "37.783699", :long => "-122.393581")
      def place_create(options={})
        post('geo/place', options)
      end
    end
  end
end
