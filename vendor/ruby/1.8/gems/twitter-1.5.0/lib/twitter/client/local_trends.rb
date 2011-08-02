module Twitter
  class Client
    # Defines methods related to local trends
    # @see Twitter::Client::Trends
    module LocalTrends
      # Returns the locations that Twitter has trending topic information for
      #
      # @format :json, :xml
      # @authenticated false
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [Float] :lat If provided with a :long option the available trend locations will be sorted by distance, nearest to furthest, to the co-ordinate pair. The valid ranges for latitude are -90.0 to +90.0 (North is positive) inclusive.
      # @option options [Float] :long If provided with a :lat option the available trend locations will be sorted by distance, nearest to furthest, to the co-ordinate pair. The valid ranges for longitude are -180.0 to +180.0 (East is positive) inclusive.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/trends/available
      # @example Return the locations that Twitter has trending topic information for
      #   Twitter.trend_locations
      def trend_locations(options={})
        response = get('trends/available', options)
        format.to_s.downcase == 'xml' ? response['locations'] : response
      end

      # Returns the top 10 trending topics for a specific WOEID
      #
      # @format :json, :xml
      # @authenticated false
      # @rate_limited true
      # @param woeid [Integer] The {http://developer.yahoo.com/geo/geoplanet Yahoo! Where On Earth ID} of the location to return trending information for. WOEIDs can be retrieved by calling {Twitter::Client::LocalTrends#trend_locations}. Global information is available by using 1 as the WOEID.
      # @param options [Hash] A customizable set of options.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/trends/:woeid
      # @example Return the top 10 trending topics for San Francisco
      #   Twitter.local_trends(2487956)
      def local_trends(woeid=1, options={})
        response = get("trends/#{woeid}", options)
        format.to_s.downcase == 'xml' ? response['matching_trends'].first.trend : response.first.trends.map{|trend| trend.name}
      end
    end
  end
end
