require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'haml'
require 'httparty'

def resource_host
  url = "http://localhost:"
  if ENV["DIASPORA_PORT"]
    url << ENV["DIASPORA_PORT"]
  else
    url << "3000"
  end
  url
end

CLIENT_ID = 'abcdefgh12345678'
CLIENT_SECRET = 'secret'
RESOURCE_HOST = resource_host

enable :sessions

helpers do
  def redirect_uri
    "http://" + request.host_with_port + "/callback"
  end

  def access_token
    session[:access_token]
  end

  def get_with_access_token(path)
    HTTParty.get(RESOURCE_HOST + path, :query => {:oauth_token => access_token})
  end

  def authorize_url
    RESOURCE_HOST + "/oauth/authorize?client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}&redirect_uri=#{redirect_uri}"
  end

  def access_token_url
    RESOURCE_HOST + "/oauth/access_token"
  end
end

get '/' do
  haml :home
end

get '/callback' do
  unless params["error"]
    response = HTTParty.post(access_token_url, :body => {
      :client_id => CLIENT_ID,
      :client_secret => CLIENT_SECRET,
      :redirect_uri => redirect_uri,
      :code => params["code"],
      :grant_type => 'authorization_code'}
    )

    session[:access_token] = response["access_token"]
    redirect '/account'
  else
    "What is your major malfunction?"
  end
end

get '/account' do
  if access_token
    @resource_server = RESOURCE_HOST
    @url = "/api/v0/me.json"
    @resource_response = get_with_access_token(@url)
    haml :response
  else
    redirect authorize_url
  end
end
