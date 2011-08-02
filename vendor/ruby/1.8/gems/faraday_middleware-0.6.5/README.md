Faraday Middleware
==================

A collection of some useful [Faraday](https://github.com/technoweenie/faraday) middleware

Installation
------------
    gem install faraday_middleware

Examples
--------
Let's decode the response body with [MultiJson](https://github.com/intridea/multi_json)!

    connection = Faraday.new(:url => 'http://api.twitter.com/1') do |builder|
      builder.use Faraday::Response::ParseJson
      builder.adapter Faraday.default_adapter
    end

    response = connection.get do |request|
      request.url '/users/show.json', :screen_name => 'pengwynn'
    end

    u = response.body
    u['name']
    # => "Wynn Netherland"

Want to ditch the brackets and use dot notation? [Mashify](https://github.com/intridea/hashie) it!

    connection = Faraday.new(:url => 'http://api.twitter.com/1') do |builder|
      builder.use Faraday::Response::Mashify
      builder.use Faraday::Response::ParseJson
      builder.adapter Faraday.default_adapter
    end

    response = connection.get do |request|
      request.url '/users/show.json', :screen_name => 'pengwynn'
    end

    u = response.body
    u.name
    # => "Wynn Netherland"
