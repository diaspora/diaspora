require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'haml'
require 'httparty'
require 'json'

def resource_host
  url = "http://localhost:"
  if ENV["DIASPORA_PORT"]
    url << ENV["DIASPORA_PORT"]
  else
    url << "3000"
  end
  url
end

@@client_id = nil
@@client_secret = nil
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
    RESOURCE_HOST + "/oauth/authorize?client_id=#{@@client_id}&client_secret=#{@@client_secret}&redirect_uri=#{redirect_uri}"
  end

  def token_url
    RESOURCE_HOST + "/oauth/token"
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

   if(params["client_id"] && params["client_secret"])
      @@client_id = params["client_id"]
      @@client_secret = params["client_secret"]
      redirect '/account'

    else
      response = HTTParty.post(access_token_url, :body => {
        :client_id => @@client_id,
        :client_secret => @@client_secret,
        :redirect_uri => redirect_uri,
        :code => params["code"],
        :grant_type => 'authorization_code'}
      )

      session[:access_token] = response["access_token"]
      redirect '/account'
    end
  else
    "What is your major malfunction?"
  end
end

get '/account' do
  if !@@client_id && !@@client_secret
    response = HTTParty.post(token_url, :body => {
      :type => :client_associate,
      :manifest_url => "http://" + request.host_with_port + "/manifest"
    })

    json = JSON.parse(response.body)

    @@client_id = json["client_id"]
    @@client_secret = json["client_secret"]
    
    redirect '/account'
  else
    if access_token
      @resource_response = get_with_access_token("/api/v0/me")
      haml :response
    else
      redirect authorize_url
    end
  end
end

get '/manifest' do
  {
    :name => "Chubbies",
    :description => "Chubbies tests Diaspora's OAuth capabilities.",
    :homepage_url => "http://" + request.host_with_port,
    :icon_url => "http://" + request.host_with_port + "/chubbies.jpeg"
  }.to_json
end

get '/reset' do
  @@client_id = nil
  @@client_secret = nil
end
