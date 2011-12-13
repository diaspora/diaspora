module Chubbies
  require 'active_record'
  require 'jwt'
  require 'diaspora-client'
  require 'haml'

  def self.reset_db
    `rm -f #{File.expand_path('../chubbies.sqlite3', __FILE__)}`
    ActiveRecord::Base.establish_connection(
        :adapter => "sqlite3",
        :database  => "chubbies.sqlite3"
    )

    ActiveRecord::Schema.define do
      create_table :resource_servers do |t|
        t.string :client_id,     :limit => 40,  :null => false
        t.string :client_secret, :limit => 40,  :null => false
        t.string :host,          :limit => 127, :null => false
        t.timestamps
      end
      add_index :resource_servers, :host, :unique => true

      create_table :access_tokens do |t|
        t.integer :user_id, :null => false
        t.integer :resource_server_id, :null => false
        t.string  :access_token, :limit => 40, :null => false
        t.string  :refresh_token, :limit => 40, :null => false
        t.string  :uid, :limit => 40, :null => false
        t.datetime :expires_at
        t.timestamps
      end
      add_index :access_tokens, :user_id, :unique => true
      create_table :users do |t|
        t.string :username, :limit => 127
        t.timestamps
      end
    end
  end

  self.reset_db

  class User < ActiveRecord::Base
    has_one :access_token, :class_name => "DiasporaClient::AccessToken", :dependent => :destroy
  end

  DiasporaClient.config do |d|
    d.private_key_path = File.dirname(__FILE__) + "/chubbies.private.pem"
    d.public_key_path = File.dirname(__FILE__) + "/chubbies.public.pem"
    d.test_mode = true
    d.application_base_url = "localhost:9292/"

    d.manifest_field(:name, "Chubbies")
    d.manifest_field(:description, "The best way to chub.")
    d.manifest_field(:icon_url, "chubbies.jpeg")

    d.manifest_field(:permissions_overview, "Chubbi.es wants to post photos to your stream.")

    d.permission(:profile, :read, "Chubbi.es wants to view your profile so that it can show it to other users.")
    d.permission(:photos, :write, "Chubbi.es wants to write to your photos to share your findings with your contacts.")
  end

  class App < DiasporaClient::App
    def current_user
      @user = User.first
    end

    def current_user= user
      @user = user
    end

    def redirect_path
      '/callback'
    end

    def after_oauth_redirect_path
      '/account?id=1'
    end

    def create_account(hash)
      hash[:username] = hash.delete(:diaspora_id)
      User.create(hash)
    end

    get '/account' do
      if params['id'] && user = User.where(:id => params['id']).first
        if user.access_token
          begin
            @resource_response = user.access_token.token.get("/api/v0/me")
            haml :response
          rescue OAuth2::Error
            "Token invalid"
          end
        else
          "No access token."
        end
      else
        "No user with id #{params['id']}"
      end
    end

    get '/new' do
      haml :home
    end

    get '/manifest.json' do
      DiasporaClient.package_manifest
    end

    get '/reset' do
      Chubbies.reset_db
    end

    post '/register' do
      DiasporaClient::ResourceServer.create!(params)
    end

    get '/user_count' do
      User.count.to_s
    end
  end
end
