#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "sidekiq/web"
require "sidekiq/cron/web"
Sidekiq::Web.set :sessions, false # disable rack session cookie

Diaspora::Application.routes.draw do

  resources :report, except: %i(edit new show)

  constraints ->(req) { req.env["warden"].authenticate?(scope: :user) &&
                        req.env['warden'].user.admin? } do
    mount Sidekiq::Web => '/sidekiq', :as => 'sidekiq'
  end

  # Federation
  mount DiasporaFederation::Engine => "/"

  get "/atom.xml" => redirect('http://blog.diasporafoundation.org/feed/atom') #too many stupid redirects :()

  get 'oembed' => 'posts#oembed', :as => 'oembed'
  # Posting and Reading
  resources :reshares, only: %i(create)

  resources :status_messages, :only => [:new, :create]

  resources :posts, only: %i(show destroy) do
    member do
      get :interactions
      get :mentionable
    end

    resource :participation, only: %i(create destroy)
    resources :poll_participations, only: :create
    resources :likes, only: %i(create destroy index)
    resources :comments, only: %i(new create destroy index)
    resources :reshares, only: :index
  end

  get 'p/:id' => 'posts#show', :as => 'short_post'

  # roll up likes into a nested resource above
  resources :comments, :only => [:create, :destroy] do
    resources :likes, :only => [:create, :destroy, :index]
  end

  # Streams
  get "activity" => "streams#activity", :as => "activity_stream"
  get "stream" => "streams#multi", :as => "stream"
  get "public" => "streams#public", :as => "public_stream"
  get "followed_tags" => "streams#followed_tags", :as => "followed_tags_stream"
  get "mentions" => "streams#mentioned", :as => "mentioned_stream"
  get "liked" => "streams#liked", :as => "liked_stream"
  get "commented" => "streams#commented", :as => "commented_stream"
  get "aspects" => "streams#aspects", :as => "aspects_stream"

  resources :aspects, except: %i(index new edit) do
    put :toggle_contact_visibility
    put :toggle_chat_privilege
    collection do
      put "order" => :update_order
    end
  end

  get 'bookmarklet' => 'status_messages#bookmarklet'

  resources :photos, only: %i(destroy create) do
    put :make_profile_photo
  end

	#Search
	get 'search' => "search#search"

  resources :conversations, except: %i(edit update destroy)  do
    resources :messages, only: %i(create)
    delete 'visibility' => 'conversation_visibilities#destroy'
    get "raw"
  end

  resources :notifications, :only => [:index, :update] do
    collection do
      get :read_all
    end
  end


  resources :tags, :only => [:index]

  resources "tag_followings", only: %i(create destroy index) do
    collection do
      get :manage
    end
  end

  get 'tags/:name' => 'tags#show', :as => 'tag'

  # Users and people

  resource :user, only: %i(edit destroy), shallow: true do
    put :edit, action: :update
    post :export_profile
    get :download_profile
    post :export_photos
    get :download_photos
    post :auth_token
  end

  controller :users do
    get "public/:username"          => :public,                  :as => :users_public
    get "getting_started"           => :getting_started,         :as => :getting_started
    get "confirm_email/:token"      => :confirm_email,           :as => :confirm_email
    get "privacy"                   => :privacy_settings,        :as => :privacy_settings
    put "privacy"                   => :update_privacy_settings, :as => :update_privacy_settings
    get "getting_started_completed" => :getting_started_completed
  end

  devise_for :users, controllers: {sessions: :sessions}, skip: :registration
  devise_scope :user do
    get "/users/sign_up" => "registrations#new",    :as => :new_user_registration
    post "/users"        => "registrations#create", :as => :user_registration
  end

  get "users/invitations"  => "invitations#new",    :as => "new_user_invitation"
  post "users/invitations" => "invitations#create", :as => "user_invitation"

  get 'login' => redirect('/users/sign_in')

  # Admin backend routes

  scope "admins", controller: :admins do
    match :user_search, via: [:get, :post]
    get :admin_inviter
    get :weekly_user_stats
    get :stats, as: "pod_stats"
    get :dashboard, as: "admin_dashboard"
    get "add_invites/:invite_code_id" => "admins#add_invites", :as => "add_invites"
  end

  namespace :admin do
    resources :pods, only: :index do
      post :recheck
    end

    post 'users/:id/close_account' => 'users#close_account', :as => 'close_account'
    post 'users/:id/lock_account' => 'users#lock_account', :as => 'lock_account'
    post 'users/:id/unlock_account' => 'users#unlock_account', :as => 'unlock_account'
  end

  resource :profile, :only => [:edit, :update]
  resources :profiles, :only => [:show]


  resources :contacts, only: %i(index)
  resources :aspect_memberships, :only  => [:destroy, :create]
  resources :share_visibilities,  :only => [:update]
  resources :blocks, :only => [:create, :destroy]

  get 'i/:id' => 'invitation_codes#show', :as => 'invite_code'

  get 'people/refresh_search' => "people#refresh_search"
  resources :people, only: %i(show index) do
    resources :status_messages, only: %i(new create)
    resources :photos, except:  %i(new update)
    get :contacts
    get :stream
    get :hovercard

    collection do
      post 'by_handle' => :retrieve_remote, :as => 'person_by_handle'
    end
  end
  get '/u/:username' => 'people#show', :as => 'user_profile', :constraints => { :username => /[^\/]+/ }

  # External

  resources :services, :only => [:index, :destroy]
  controller :services do
    scope "/auth", :as => "auth" do
      get ':provider/callback' => :create
      get :failure
    end
  end

  get 'community_spotlight' => "contacts#spotlight", :as => 'community_spotlight'
  # Mobile site

  get 'mobile/toggle', :to => 'home#toggle_mobile', :as => 'toggle_mobile'
  get "/m", to: "home#force_mobile", as: "force_mobile"

  # Help
  get 'help' => 'help#faq', :as => 'help'
  get 'help/:topic' => 'help#faq'

  #Protocol Url
  get 'protocol' => redirect("http://wiki.diasporafoundation.org/Federation_Protocol_Overview")

  # NodeInfo
  get ".well-known/nodeinfo", to: "node_info#jrd"
  get "nodeinfo/:version",    to: "node_info#document", as: "node_info", constraints: {version: /\d+\.\d+/}
  get "statistics",           to: "node_info#statistics"

  # Terms
  if AppConfig.settings.terms.enable? || Rails.env.test?
    get 'terms' => 'terms#index'
  end

  # Relay
  get ".well-known/x-social-relay" => "social_relay#well_known"

  # Startpage
  root :to => 'home#show'
  get "podmin", to: "home#podmin"

  namespace :api do
    namespace :openid_connect do
      resources :clients, only: :create
      get "clients/find", to: "clients#find"

      post "access_tokens", to: "token_endpoint#create"

      # Authorization Servers MUST support the use of the HTTP GET and POST methods at the Authorization Endpoint
      # See http://openid.net/specs/openid-connect-core-1_0.html#AuthResponseValidation
      resources :authorizations, only: %i(new create destroy)
      post "authorizations/new", to: "authorizations#new"
      get "user_applications", to: "user_applications#index"
      get "jwks.json", to: "id_tokens#jwks"
      match "user_info", to: "user_info#show", via: %i(get post)
    end
  end

  get ".well-known/webfinger", to: "api/openid_connect/discovery#webfinger"
  get ".well-known/openid-configuration", to: "api/openid_connect/discovery#configuration"
end
