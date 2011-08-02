require 'spec_helper'

describe "A request for a protected resource" do
  action do |env|
    env['oauth2'].authenticate_request!(:scope => nil) do
      successful_response
    end
  end

  before :each do
    @token = create_access_token(
      :authorization => create_authorization(
        :scope => "protected write"
      )
    )
  end

  describe "with no token passed" do
    before :each do
      get "/protected"
    end

    responds_with_status 401
    responds_with_header 'WWW-Authenticate', 'OAuth2'
  end

  describe "with a token passed as an oauth_token parameter" do
    before :each do
      get "/protected", :oauth_token => @token.access_token
    end

    it "is successful" do
      response.should be_successful
    end

    it "makes the access token available to the requested action" do
      response.body.should == "Success"
    end
  end

  describe "with a token passed in an Authorization header" do
    before :each do
      get "/protected", {}, {"HTTP_AUTHORIZATION" => "OAuth #{@token.access_token}"}
    end

    it "is successful" do
      response.should be_successful
    end

    it "makes the access token available to the requested action" do
      response.body.should == "Success"
    end
  end

  describe "with same token passed in both the Authorization header and oauth_token parameter" do
    before :each do
      get "/protected", {:oauth_token => @token.access_token}, {"HTTP_AUTHORIZATION" => "OAuth #{@token.access_token}"}
    end

    it "is successful" do
      response.should be_successful
    end

    it "makes the access token available to the requested action" do
      response.body.should == "Success"
    end
  end

  describe "with different tokens passed in both the Authorization header and oauth_token parameter" do
    before :each do
      get "/protected", {:oauth_token => @token.access_token}, {"HTTP_AUTHORIZATION" => "OAuth DifferentToken"}
    end

    responds_with_json_error 'invalid_request', :description => 'both authorization header and oauth_token provided, with conflicting tokens', :status => 400
  end

  describe "with an invalid token" do
    before :each do
      get "/protected", :oauth_token => 'invalid-token'
    end

    responds_with_status 401
    responds_with_header 'WWW-Authenticate', 'OAuth2 error="invalid_token"'
  end

  describe "with an expired token that can be refreshed" do
    before :each do
      @token.update_attributes(:expires_at => 1.day.ago)
      get "/protected", :oauth_token => @token.access_token
    end

    responds_with_status 401
    responds_with_header 'WWW-Authenticate', 'OAuth2 error="invalid_token"'
  end

  describe "with an expired token that can't be refreshed" do
    before :each do
      @token.update_attributes(:expires_at => 1.day.ago, :refresh_token => nil)
      get "/protected", :oauth_token => @token.access_token
    end

    responds_with_status 401
    responds_with_header 'WWW-Authenticate', 'OAuth2 error="invalid_token"'
  end

  describe "when warden is part of the stack" do
    it "bypasses warden when no token is passed" do
      warden = "warden"
      warden.should_receive(:custom_failure!)
      get "/protected", {}, {'warden' => warden}
    end

    it "bypasses warden when token invalid" do
      warden = "warden"
      warden.should_receive(:custom_failure!)
      get "/protected", {:oauth_token => 'invalid_token'}, {'warden' => warden}
    end
  end
end

describe "A request for a protected resource requiring a specific scope" do
  action do |env|
    env['oauth2'].authenticate_request!(:scope => 'omnipotent') do
      successful_response
    end
  end

  before :each do
    @token = create_access_token(:authorization => create_authorization(:scope => "omnipotent admin"))
    @insufficient_token = create_access_token(:authorization => create_authorization(:scope => "impotent admin"))
  end

  describe "made with a token with sufficient scope" do
    before :each do
      get '/protected_by_scope', :oauth_token => @token.access_token
    end

    it "is successful" do
      response.should be_successful
    end
  end

  describe "made with a token with insufficient scope" do
    before :each do
      get '/protected_by_scope', :oauth_token => @insufficient_token.access_token
    end

    responds_with_json_error 'insufficient_scope', :status => 403
  end
end
