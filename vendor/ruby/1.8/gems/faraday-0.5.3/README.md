# faraday

Modular HTTP client library using middleware heavily inspired by Rack.

This mess is gonna get raw, like sushi. So, haters to the left.

## Usage

    conn = Faraday::Connection.new(:url => 'http://sushi.com') do |builder|
      builder.use Faraday::Request::Yajl        # convert body to json with Yajl lib
      builder.use Faraday::Adapter::Logger      # log the request somewhere?
      builder.use Faraday::Adapter::Typhoeus    # make http request with typhoeus
      builder.use Faraday::Adapter::EMSynchrony # make http request with eventmachine and synchrony
      builder.use Faraday::Response::Yajl       # parse body with yajl

      # or use shortcuts
      builder.request  :yajl         # Faraday::Request::Yajl
      builder.adapter  :logger       # Faraday::Adapter::Logger
      builder.adapter  :typhoeus     # Faraday::Adapter::Typhoeus
      builder.adapter  :em_synchrony # Faraday::Adapter::EMSynchrony
      builder.response :yajl         # Faraday::Response::Yajl
    end

    resp1 = conn.get '/nigiri/sake.json'
    resp2 = conn.post do |req|
      req.url  "/nigiri.json", :page => 2
      req["Content-Type"] = 'application/json'
      req.body = {:name => 'Unagi'}
    end

    # If you're ready to roll with just the bare minimum (net/http):
    resp1 = Faraday.get 'http://sushi.com/nigiri/sake.json'

## Testing

    # It's possible to define stubbed request outside a test adapter block.
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/tamago') { [200, {}, 'egg'] }
    end

    # You can pass stubbed request to the test adapter or define them in a block
    # or a combination of the two.
    test = Faraday::Connection.new do |builder|
      builder.adapter :test, stubs do |stub|
        stub.get('/ebi') {[ 200, {}, 'shrimp' ]}
      end
    end

    # It's also possible to stub additional requests after the connection has
    # been initialized. This is useful for testing.
    stubs.get('/uni') {[ 200, {}, 'urchin' ]}

    resp = test.get '/tamago'
    resp.body # => 'egg'
    resp = test.get '/ebi'
    resp.body # => 'shrimp'
    resp = test.get '/uni'
    resp.body # => 'urchin'
    resp = test.get '/else' #=> raises "no such stub" error

    # If you like, you can treat your stubs as mocks by verifying that all of 
    # the stubbed calls were made. NOTE that this feature is still fairly
    # experimental: It will not verify the order or count of any stub, only that
    # it was called once during the course of the test.
    stubs.verify_stubbed_calls

## TODO

* support streaming requests/responses
* better stubbing API
* Support timeouts
* Add curb, em-http, fast_http

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2009-2010 rick, hobson. See LICENSE for details.
