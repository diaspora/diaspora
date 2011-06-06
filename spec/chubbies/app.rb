require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'haml'
require 'httparty'
require 'json'
require 'active_record'
require 'pp'

# models ======================================
`rm -f #{File.expand_path('../chubbies.sqlite3', __FILE__)}`
ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database  => "chubbies.sqlite3"
)

ActiveRecord::Schema.define do
  create_table :users do |table|
      table.string :diaspora_handle
      table.string :access_token
      table.integer :pod_id
  end

  create_table :pods do |table|
      table.string :host
      table.string :client_id
      table.string :client_secret
  end
end

class User < ActiveRecord::Base
  attr_accessible :diaspora_handle, :access_token
  belongs_to :pod
end

class Pod < ActiveRecord::Base
  attr_accessible :host, :client_id, :client_secret
  has_many :users

  def authorize_url(redirect_uri)
    "http://" + host + "/oauth/authorize?client_id=#{client_id}&client_secret=#{client_secret}&redirect_uri=#{redirect_uri}"
  end

  def token_url
    "http://" + host + "/oauth/token"
  end

  def access_token_url
    "http://" + host + "/oauth/access_token"
  end
end

helpers do
  def redirect_uri
    "http://" + request.host_with_port + "/callback" << "?diaspora_handle=#{params['diaspora_handle']}"
  end

  def get_with_access_token(user, path)
    HTTParty.get('http://' + user.pod.host + path, :query => {:oauth_token => user.access_token})
  end
end

get '/' do
  @pods = Pod.scoped.includes(:users).all
  haml :home
end

get '/callback' do
  unless params["error"]
    pod = Pod.where(:host => domain_from_handle).first

    response = HTTParty.post(pod.access_token_url, :body => {
      :client_id => pod.client_id,
      :client_secret => pod.client_secret,
      :redirect_uri => redirect_uri,
      :code => params["code"],
      :grant_type => 'authorization_code'}
    )
    
    user = pod.users.create!(:access_token => response["access_token"] )
    redirect "/account?id=#{user.id}"
  else
    "What is your major malfunction?"
  end
end

get '/account' do
  # have diaspora handle
  if params[:diaspora_handle]
    host = domain_from_handle
    unless pod = Pod.where(:host => host).first
      pod = register_with_pod
    end
  end

  if params['id'] && user = User.where(:id => params['id']).first
    @resource_response = get_with_access_token(user, "/api/v0/me")
    haml :response
  else
    redirect pod.authorize_url(redirect_uri)
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
  User.delete_all
  Pod.delete_all
  "reset."
end
#=============================
#helpers
#
def domain_from_handle
 m = params['diaspora_handle'].match(/\@(.+)/) 
 m = m[1] if m
end

def register_with_pod
  pod = Pod.new(:host => domain_from_handle)
  
  response = HTTParty.post(pod.token_url, :body => {
    :type => :client_associate,
    :manifest_url => "http://" + request.host_with_port + "/manifest"
  })

  json = JSON.parse(response.body)
  pod.update_attributes(json)

  pod.save!
  pod
end

