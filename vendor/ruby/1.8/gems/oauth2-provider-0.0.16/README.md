oauth2-provider
==

Simple OAuth2 provider code extracted from [hashblue.com](https://hashblue.com/)

Details
--

* Implements [draft 11](http://tools.ietf.org/html/draft-ietf-oauth-v2-11) of the oauth2 spec
* Handles the authorization_code and password grant types
* Supports ActiveRecord and Mongoid

Usage Instructions
--

In your Gemfile:

    gem 'oauth2-provider', :git => 'git@github.com:freerange/oauth2-provider.git'

If you're using ActiveRecord, grab the schema out of `spec/schema.rb`, and run the migration.

To dish out authorization codes you will need to implement something like this:

    class AuthorizationController < ApplicationController
      include OAuth2::Provider::Rack::AuthorizationCodesSupport

      before_filter :authenticate_user!
      before_filter :block_invalid_authorization_code_requests

      def new
        @client = oauth2_authorization_request.client
      end

      def create
        if params[:yes].present?
          grant_authorization_code(current_user)
        else
          deny_authorization_code
        end
      end

    end
        
And add a couple of routes:

    match "/oauth/authorize", :via => :get, :to => "authorization#new"
    match "/oauth/authorize", :via => :post, :to => "authorization#create"

oauth2-provider will handle requests to `/oauth/access_token` to handle conversion of authorization codes to access tokens.
