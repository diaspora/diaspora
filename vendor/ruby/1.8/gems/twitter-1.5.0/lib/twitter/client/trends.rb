module Twitter
  class Client
    # Defines methods related to global trends
    # @see Twitter::Client::LocalTrends
    module Trends
      # Returns the top ten topics that are currently trending on Twitter
      #
      # @format :json
      # @authenticated false
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/trends
      # @example Return the top ten topics that are currently trending on Twitter
      #   Twitter.trends
      def trends(options={})
        get('trends', options)['trends']
      end

      # Returns the current top 10 trending topics on Twitter
      #
      # @format :json
      # @authenticated false
      # @rate_limited true
      # @param options [Hash] A customizable set of options.
      # @option options [String] :exclude Setting this equal to 'hashtags' will remove all hashtags from the trends list.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/trends/current
      # @example Return the current top 10 trending topics on Twitter
      #   Twitter.trends_current
      def trends_current(options={})
        get('trends/current', options)['trends']
      end

      # Returns the top 20 trending topics for each hour in a given day
      #
      # @format :json
      # @authenticated false
      # @rate_limited true
      # @param date [Date] The start date for the report. A 404 error will be thrown if the date is older than the available search index (7-10 days). Dates in the future will be forced to the current date.
      # @param options [Hash] A customizable set of options.
      # @option options [String] :exclude Setting this equal to 'hashtags' will remove all hashtags from the trends list.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/trends/daily
      # @example Return the top 20 trending topics for each hour of October 24, 2010
      #   Twitter.trends_daily(Date.parse("2010-10-24"))
      def trends_daily(date=Date.today, options={})
        get('trends/daily', options.merge(:date => date.strftime('%Y-%m-%d')))['trends']
      end

      # Returns the top 30 trending topics for each day in a given week
      #
      # @format :json
      # @authenticated false
      # @rate_limited true
      # @param date [Date] The start date for the report. A 404 error will be thrown if the date is older than the available search index (7-10 days). Dates in the future will be forced to the current date.
      # @param options [Hash] A customizable set of options.
      # @option options [String] :exclude Setting this equal to 'hashtags' will remove all hashtags from the trends list.
      # @return [Array]
      # @see http://dev.twitter.com/doc/get/trends/weekly
      # @example Return the top ten topics that are currently trending on Twitter
      #   Twitter.trends_weekly(Date.parse("2010-10-24"))
      def trends_weekly(date=Date.today, options={})
        get('trends/weekly', options.merge(:date => date.strftime('%Y-%m-%d')))['trends']
      end
    end
  end
end
