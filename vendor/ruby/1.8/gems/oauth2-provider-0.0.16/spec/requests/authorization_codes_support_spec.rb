require 'spec_helper'

describe OAuth2::Provider::Rack::AuthorizationCodesSupport do
  before :each do
    ExampleResourceOwner.destroy_all
    @client = OAuth2::Provider.client_class.create! :name => 'client'
    @valid_params = {
      :client_id => @client.oauth_identifier,
      :redirect_uri => "https://redirect.example.com/callback"
    }
    @owner = create_resource_owner
  end

  describe "Validating requests" do
    action do |env|
      request = Rack::Request.new(env)
      env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(env, request.params)
      env['oauth2.authorization_request'].validate!
      successful_response
    end

    describe "Any request with a client_id and redirect_uri" do
      before :each do
        get '/oauth/authorize', @valid_params
      end

      it "is successful" do
        response.status.should == 200
      end
    end

    describe "Any request without a client_id" do
      before :each do
        get '/oauth/authorize', @valid_params.except(:client_id)
      end

      redirects_back_with_error 'invalid_request'
    end

    describe "Any request without a redirect_uri" do
      before :each do
        get '/oauth/authorize', @valid_params.except(:redirect_uri)
      end

      it "returns 400" do
        response.status.should == 400
      end
    end

    describe "Any request with an invalid redirect_uri" do
      before :each do
        get '/oauth/authorize', @valid_params.merge(:redirect_uri => "http://")
      end

      it "returns 400" do
        response.status.should == 400
      end
    end

    describe "Any request with an unknown client id" do
      before :each do
        get '/oauth/authorize', @valid_params.merge(:client_id => 'unknown')
      end

      redirects_back_with_error 'invalid_client'
    end

    describe "A request where the scope is declared invalid" do
      action do |env|
        request = Rack::Request.new(env)
        env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(env, request.params)
        env['oauth2.authorization_request'].validate!
        env['oauth2.authorization_request'].invalid_scope!
        successful_response
      end

      before :each do
        get '/oauth/authorize', @valid_params
      end

      redirects_back_with_error 'invalid_scope'
    end
  end

  describe "Granting a code" do
    action do |env|
      request = Rack::Request.new(env)
      env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(env, request.params)
      env['oauth2.authorization_request'].grant! ExampleResourceOwner.first
    end

    before :each do
      post '/oauth/authorize', @valid_params.merge(:submit => 'Yes')
    end

    it "redirects back to the redirect_uri with a valid authorization code for the client" do
      response.status.should == 302
      code = Addressable::URI.parse(response.location).query_values["code"]
      code.should_not be_nil
      found = OAuth2::Provider.authorization_code_class.find_by_code(code)
      found.should_not be_nil
      found.authorization.client.should == @client
      found.authorization.resource_owner.should == @owner
      found.should_not be_expired
    end
  end

  describe "Granting a code with a scope" do
    action do |env|
      request = Rack::Request.new(env)
      env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(env, request.params)
      env['oauth2.authorization_request'].grant! ExampleResourceOwner.first
    end

    before :each do
      post '/oauth/authorize', @valid_params.merge(:submit => 'Yes', :scope => 'periscope')
    end

    it "includes the scope in the granted authorization" do
      code = Addressable::URI.parse(response.location).query_values["code"]
      found = OAuth2::Provider.authorization_code_class.find_by_code(code)
      found.authorization.scope.should == 'periscope'
    end
  end

  describe "Granting a code with custom authorization length" do
    action do |env|
      request = Rack::Request.new(env)
      env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(env, request.params)
      env['oauth2.authorization_request'].grant! ExampleResourceOwner.first, 5.years.from_now
    end

    before :each do
      post '/oauth/authorize', @valid_params.merge(:submit => 'Yes', :five_years => 'true')
    end

    it "redirects with an authorization code linked to the extended authorization" do
      code = Addressable::URI.parse(response.location).query_values["code"]
      found = OAuth2::Provider.authorization_code_class.find_by_code(code)
      found.authorization.expires_at.should eql(5.years.from_now)
    end
  end

  describe "Denying a code" do
    action do |env|
      request = Rack::Request.new(env)
      env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(env, request.params)
      env['oauth2.authorization_request'].deny!
    end

    before :each do
      post '/oauth/authorize', @valid_params.merge(:submit => 'No')
    end

    redirects_back_with_error 'access_denied'
  end
end
