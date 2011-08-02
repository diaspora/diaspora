OAuth2
======
A Ruby wrapper for the OAuth 2.0 specification. This is a work in progress, being built first to solve the pragmatic process of connecting to existing OAuth 2.0 endpoints (a.k.a. Facebook) with the goal of building it up to meet the entire specification over time.

Installation
------------
    gem install oauth2

Continuous Integration
----------------------
[![Build Status](http://travis-ci.org/intridea/oauth2.png)](http://travis-ci.org/intridea/oauth2)

Resources
---------
* View Source on GitHub (https://github.com/intridea/oauth2)
* Report Issues on GitHub (https://github.com/intridea/oauth2/issues)
* Read More at the Wiki (https://wiki.github.com/intridea/oauth2)

Web Server Example (Sinatra)
----------------------------
Below is a fully functional example of a Sinatra application that would authenticate to Facebook utilizing the OAuth 2.0 web server flow.

    require 'rubygems'
    require 'sinatra'
    require 'oauth2'
    require 'json'
    
    def client
      OAuth2::Client.new('app_id', 'app_secret', :site => 'https://graph.facebook.com')
    end
    
    get '/auth/facebook' do
      redirect client.web_server.authorize_url(
        :redirect_uri => redirect_uri,
        :scope => 'email,offline_access'
      )
    end
    
    get '/auth/facebook/callback' do
      access_token = client.web_server.get_access_token(params[:code], :redirect_uri => redirect_uri)
      user = JSON.parse(access_token.get('/me'))
      user.inspect
    end
    
    def redirect_uri
      uri = URI.parse(request.url)
      uri.path = '/auth/facebook/callback'
      uri.query = nil
      uri.to_s
    end

That's all there is to it! You can use the access token like you would with the
OAuth gem, calling HTTP verbs on it etc. You can view more examples on the [OAuth2
Wiki](http://wiki.github.com/intridea/oauth2/examples).

JSON Parsing
------------
Because JSON has become the standard format of the OAuth 2.0 specification,
the <tt>oauth2</tt> gem contains a mode that will perform automatic parsing
of JSON response bodies, returning a hash instead of a string. To enable this
mode, simply add the <tt>:parse_json</tt> option to your client initialization:

    client = OAuth2::Client.new(
      'app_id',
      'app_secret',
      :site => 'https://example.com',
      :parse_json => true,
    )
    
    # Obtain an access token using the client
    token.get('/some/url.json') #=> {"some" => "hash"}

Testing
-------
To use the OAuth2 client for testing error conditions do:

    my_client.raise_errors = false

It will then return the error status and response instead of raising an exception.

Note on Patches/Pull Requests
-----------------------------
1. Fork the project.
2. Create a topic branch.
3. Implement your feature or bug fix.
4. Add documentation for your feature or bug fix.
5. Add specs for your feature or bug fix.
6. Run <tt>bundle exec rake spec</tt>. If your changes are not 100% covered, go back to step 5.
7. Commit and push your changes.
8. Submit a pull request. Please do not include changes to the [gemspec](https://github.com/intridea/oauth2/blob/master/oauth2.gemspec), [version](https://github.com/intridea/oauth2/blob/master/lib/oauth2/version.rb), or [changelog](https://github.com/intridea/oauth2/blob/master/CHANGELOG.md) file. (If you want to create your own version for some reason, please do so in a separate commit.)

Copyright
---------
Copyright (c) 2011 Intridea, Inc. and Michael Bleigh.
See [LICENSE](https://github.com/intridea/oauth2/blob/master/LICENSE.md) for details.
