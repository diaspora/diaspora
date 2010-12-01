require File.join(File.expand_path(File.dirname(__FILE__)), "local_trends")

module Twitter
  class Trends
    include HTTParty

    def self.api_endpoint
      @api_endpoint ||= "api.twitter.com/#{Twitter.api_version}/trends"
    end

    def self.api_endpoint=(value)
      @api_endpoint = value
    end

    # :exclude => 'hashtags' to exclude hashtags
    def self.current(options={})
      get("/current.json", :query => options)
    end

    # :exclude => 'hashtags' to exclude hashtags
    # :date => yyyy-mm-dd for specific date
    def self.daily(options={})
      get("/daily.json", :query => options)
    end

    # :exclude => 'hashtags' to exclude hashtags
    # :date => yyyy-mm-dd for specific date
    def self.weekly(options={})
      get("/weekly.json", :query => options)
    end

    def self.available(query={})
      # Checking for api_endpoint in local_trends
      LocalTrends.available(query)
    end

    def self.for_location(woeid, options={})
      # Checking for api_endpoint in local_trends
      LocalTrends.for_location(woeid, options)
    end

    private

    def self.get(*args)
      base_uri api_endpoint
      mashup(super)
    end

    def self.mashup(response)
      Twitter.parse(response)["trends"].values.flatten.map{|t| Twitter.mash(t)}
    end

  end
end
