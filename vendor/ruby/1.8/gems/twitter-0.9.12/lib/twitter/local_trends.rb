module Twitter
  class LocalTrends
    include HTTParty
    base_uri "api.twitter.com/#{Twitter.api_version}/trends"

    def self.available(query={})
      query.delete(:api_endpoint)
      mashup(get("/available.json", :query => query))
    end

    def self.for_location(woeid, options = {})
      mashup(get("/#{woeid}.json"))
    end

    private

    def self.mashup(response)
      Twitter.parse(response).map{|t| Twitter.mash(t)}
    end

  end
end
