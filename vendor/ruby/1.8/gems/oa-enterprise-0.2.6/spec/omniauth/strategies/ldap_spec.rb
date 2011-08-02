require File.expand_path('../../../spec_helper', __FILE__)
require 'cgi'

describe OmniAuth::Strategies::LDAP, :type => :strategy do

  include OmniAuth::Test::StrategyTestCase

  def strategy
    @ldap_server ||= 'ldap.example.org'
    [OmniAuth::Strategies::LDAP, {
      :host => @ldap_server,
      :port => 636,
      :method => :ssl,
      :uid => 'jeremyf',
      :base => 'o="University of OmniAuth", st=Sublime, c=RubyNation',
    }]
  end

  describe 'GET /auth/ldap' do
    before do
      get '/auth/ldap'
    end

    # TODO: Add checks that page has authentication form; I attempted
    # to use `should have_tag` but that was not working.
    it 'should get authentication page' do
      last_response.status.should == 200
    end
  end

  describe 'POST /auth/ldap' do
    before do
      post '/auth/ldap', {:username => 'jeremy', :password => 'valid_password' }
    end

    it 'should redirect us to /auth/ldap/callback' do
      last_response.should be_redirect
      last_response.location.should == '/auth/ldap/callback'
    end
  end
end