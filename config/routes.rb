#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'sidekiq/web'
require 'sidetiq/web'

Diaspora::Application.routes.draw do

  resources :report, :except => [:edit, :new]

  if Rails.env.production?
    mount RailsAdmin::Engine => '/admin_panel', :as => 'rails_admin'
  end

  constraints ->(req) { req.env["warden"].authenticate?(scope: :user) &&
                        req.env['warden'].user.admin? } do
    mount Sidekiq::Web => '/sidekiq', :as => 'sidekiq'
  end

  mount DiasporaFederation::Engine => "/"

  get "/atom.xml" => redirect('http://blog.diasporafoundation.org/feed/atom') #too many stupid redirects :()

  get 'oembed' => 'posts#oembed', :as => 'oembed'
  # Posting and Reading
  resources :reshares

  resources :status_messages, :only => [:new, :create]

  resources :posts do
    member do
      get :interactions
    end

    resource :participation, only: %i(create destroy)
    resources :poll_participations, only: :create
    resources :likes, only: %i(create destroy index)
    resources :comments, only: %i(new create destroy index)
  end



  get 'p/:id' => 'posts#show', :as => 'short_post'
  get 'posts/:id/iframe' => 'posts#iframe', :as => 'iframe'

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

  resources :aspects do
    put :toggle_contact_visibility
    put :toggle_chat_privilege
    collection do
      put "order" => :update_order
    end
  end

  get 'bookmarklet' => 'status_messages#bookmarklet'

  resources :photos, :except => [:index, :show] do
    put :make_profile_photo
  end

	#Search
	get 'search' => "search#search"

  resources :conversations do
    resources :messages, :only => [:create, :show]
    delete 'visibility' => 'conversation_visibilities#destroy'
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

  resources :apps, :only => [:show]

  # Users and people

  resource :user, :only => [:edit, :update, :destroy], :shallow => true do
    get :getting_started_completed
    post :export_profile
    get :download_profile
    post :export_photos
    get :download_photos
  end

  controller :users do
    get 'public/:username'          => :public,           :as => 'users_public'
    get 'getting_started'           => :getting_started,  :as => 'getting_started'
    get 'privacy'                   => :privacy_settings, :as => 'privacy_settings'
    get 'getting_started_completed' => :getting_started_completed
    get 'confirm_email/:token'      => :confirm_email,    :as => 'confirm_email'
  end

  # This is a hack to overide a route created by devise.
  # I couldn't find anything in devise to skip that route, see Bug #961
  get 'users/edit' => redirect('/user/edit')

  devise_for :users, :controllers => {:registrations => "registrations",
                                      :sessions      => "sessions"}

  #legacy routes to support old invite routes
  get 'users/invitation/accept' => 'invitations#edit'
  get 'invitations/email' => 'invitations#email', :as => 'invite_email'
  get 'users/invitations' => 'invitations#new', :as => 'new_user_invitation'
  post 'users/invitations' => 'invitations#create', :as => 'user_invitation'

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


  resources :contacts,           :except => [:update, :create] do
  end
  resources :aspect_memberships, :only  => [:destroy, :create]
  resources :share_visibilities,  :only => [:update]
  resources :blocks, :only => [:create, :destroy]

  get 'i/:id' => 'invitation_codes#show', :as => 'invite_code'

  get 'people/refresh_search' => "people#refresh_search"
  resources :people, :except => [:edit, :update] do
    resources :status_messages
    resources :photos
    get :contacts
    get "aspect_membership_button" => :aspect_membership_dropdown, :as => "aspect_membership_button"
    get :stream
    get :hovercard

    member do
      get :last_post
    end

    collection do
      post 'by_handle' => :retrieve_remote, :as => 'person_by_handle'
      get :tag_index
    end
  end
  get '/u/:username' => 'people#show', :as => 'user_profile', :constraints => { :username => /[^\/]+/ }
  get '/u/:username/profile_photo' => 'users#user_photo', :constraints => { :username => /[^\/]+/ }


  # Federation

  controller :publics do
    post 'receive/users/:guid'  => :receive
    post 'receive/public'       => :receive_public
    get 'hub'                   => :hub
  end



  # External

  resources :services, :only => [:index, :destroy]
  controller :services do
    scope "/auth", :as => "auth" do
      get ':provider/callback' => :create
      get :failure
    end
  end

  scope 'api/v0', :controller => :apis do
    get :me
  end

  namespace :api do
    namespace :v0 do
      get "/users/:username" => 'users#show', :as => 'user'
      get "/tags/:name" => 'tags#show', :as => 'tag'
    end
    namespace :v1 do
      resources :tokens, :only => [:create, :destroy]
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
  if AppConfig.settings.terms.enable?
    get 'terms' => 'terms#index'
  end

  # Relay
  get ".well-known/x-social-relay" => "social_relay#well_known"

  # Startpage
  root :to => 'home#show'
end
