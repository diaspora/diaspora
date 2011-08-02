require File.expand_path('../../../spec_helper', __FILE__)

describe OmniAuth::Strategies::OpenID do

end

# require File.dirname(__FILE__) + '/../../spec_helper'
#
# describe OmniAuth::Strategies::OpenID, :type => :strategy do
#
#   include OmniAuth::Test::StrategyTestCase
#
#   def strategy
#     [OmniAuth::Strategies::OpenID]
#   end
#
#   describe '/auth/open_id without an identifier URL' do
#     before do
#       get '/auth/open_id'
#     end
#
#     it 'should respond with OK' do
#       last_response.should be_ok
#     end
#
#     it 'should respond with HTML' do
#       last_response.content_type.should == 'text/html'
#     end
#
#     it 'should render an identifier URL input' do
#       last_response.body.should =~ %r{<input[^>]*#{OmniAuth::Strategies::OpenID::IDENTIFIER_URL_PARAMETER}}
#     end
#   end
#
#   describe '/auth/open_id with an identifier URL' do
#     before do
#       @identifier_url = 'http://me.example.org'
#       # TODO: change this mock to actually return some sort of OpenID response
#       stub_request(:get, @identifier_url)
#       get '/auth/open_id?openid_url=' + @identifier_url
#     end
#
#     it 'should redirect to the OpenID identity URL' do
#       last_response.should be_redirect
#       last_response.headers['Location'].should =~ %r{^#{@identifier_url}.*}
#     end
#
#     it 'should tell the OpenID server to return to the callback URL' do
#       return_to = CGI.escape(last_request.url + '/callback')
#       last_response.headers['Location'].should =~ %r{[\?&]openid.return_to=#{return_to}}
#     end
#
#   end
#
#   describe 'followed by /auth/open_id/callback' do
#     before do
#       @identifier_url = 'http://me.example.org'
#       # TODO: change this mock to actually return some sort of OpenID response
#       stub_request(:get, @identifier_url)
#       get '/auth/open_id/callback'
#     end
#
#     sets_an_auth_hash
#     sets_provider_to 'open_id'
#     sets_uid_to 'http://me.example.org'
#
#     it 'should call through to the master app' do
#       last_response.body.should == 'true'
#     end
#   end
# end
