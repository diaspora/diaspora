# Über Stack

[Faraday][] is an HTTP client lib that provides a common interface over many adapters (such as Net::HTTP) and embraces the concept of Rack middleware when processing the request/response cycle.

*“Faraday Stack”* is an add-on library that implements several middleware (such as JSON and XML parsers) and helps you build an awesome stack that covers most of your API-consuming needs.

Boring example:

    require 'faraday_stack'
    
    response = FaradayStack.get 'http://google.com'
    
    response.headers['content-type']  #=> "text/html; charset=UTF-8"
    response.headers['location']      #=> "http://www.google.com/"
    puts response.body

Awesome example:

    conn = FaradayStack.build 'http://github.com/api/v2'
    
    # JSON resource
    resp = conn.get 'json/repos/show/mislav/faraday-stack'
    resp.body
    #=> {"repository"=>{"language"=>"Ruby", "fork"=>false, ...}}
    
    # XML resource
    resp = conn.get 'xml/repos/show/mislav/faraday-stack'
    resp.body.class
    #=> Nokogiri::XML::Document
    
    # 404
    conn.get 'zomg/wrong/url'
    #=> raises Faraday::Error::ResourceNotFound

## Features

* parses JSON, XML & HTML
* raises exceptions on 4xx, 5xx responses
* follows redirects

To see how the default stack is built, see "[faraday_stack.rb][source]".

### Optional features:

* encode POST/PUT bodies as JSON:
      
        conn.post(path, payload, :content_type => 'application/json')

* add `Instrumentation` middleware to instrument requests with ActiveSupport
      
        conn.builder.insert_after Faraday::Response::RaiseError, FaradayStack::Instrumentation

* add `Caching` middleware to have GET responses cached
      
        conn.builder.insert_before FaradayStack::ResponseJSON, FaradayStack::Caching do
          ActiveSupport::Cache::FileStore.new 'tmp/cache',
            :namespace => 'faraday', :expires_in => 3600
        end

* mount [Rack::Cache][] through `RackCompatible` middleware for HTTP caching of responses
      
        conn.builder.insert_after FaradayStack::FollowRedirects, FaradayStack::RackCompatible,
          Rack::Cache::Context,
            :metastore   => "file:/var/cache/rack/meta",
            :entitystore => "file:/var/cache/rack/body"


[faraday]: https://github.com/technoweenie/faraday
[source]: https://github.com/mislav/faraday-stack/blob/master/lib/faraday_stack.rb
[rack::cache]: http://rtomayko.github.com/rack-cache/
