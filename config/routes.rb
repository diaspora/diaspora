#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

Diaspora::Application.routes.draw do


  # Posting and Reading

  resources :aspects do
    put 'toggle_contact_visibility' => :toggle_contact_visibility
  end

  resources :status_messages, :only => [:new, :create, :destroy, :show] do
    resources :likes, :only => [:create, :destroy, :index]
  end

  get 'bookmarklet' => 'status_messages#bookmarklet'
  get 'p/:id'       => 'posts#show', :as => 'post'

  resources :photos, :except => [:index] do
    put 'make_profile_photo' => :make_profile_photo
  end

  resources :comments, :only => [:create, :destroy]


  resources :conversations do
    resources :messages, :only => [:create, :show]
    delete 'visibility' => 'conversation_visibilities#destroy'
  end

  resources :notifications, :only => [:index, :update] do
    get 'read_all' => :read_all, :on => :collection
  end

  resources :tags, :only => [:index]
  post    "/tags/:name/tag_followings" => "tag_followings#create", :as => 'tag_tag_followings'
  delete  "/tags/:name/tag_followings" => "tag_followings#destroy"

  get 'tags/:name' => 'tags#show', :as => 'tag'

  resources :apps, :only => [:show]
  # Users and people

  resource :user, :only => [:edit, :update, :destroy], :shallow => true do
    get :export
    get :export_photos
  end


  controller :users do
    get 'public/:username'          => :public,          :as => 'users_public'
    match 'getting_started'         => :getting_started, :as => 'getting_started'
    get 'getting_started_completed' => :getting_started_completed
  end

  # This is a hack to overide a route created by devise.
  # I couldn't find anything in devise to skip that route, see Bug #961
  match 'users/edit' => redirect('/user/edit')

  devise_for :users, :controllers => {:registrations => "registrations",
                                      :password      => "devise/passwords",
                                      :sessions      => "sessions",
                                      :invitations   => "invitations"} do
    get 'invitations/resend/:id' => 'invitations#resend', :as => 'invitation_resend'
  end

  # generating a new user token (for devise)

  # ActivityStreams routes
  scope "/activity_streams", :module => "activity_streams", :as => "activity_streams" do
    resources :photos, :controller => "photos", :only => [:create, :show, :destroy]
  end


  #Temporary token_authenticable route
  resource :token, :only => :show

  get 'login' => redirect('/users/sign_in')

  scope 'admins', :controller => :admins do
    match 'user_search'   => :user_search
    get   'admin_inviter' => :admin_inviter
    get   'add_invites'   => :add_invites, :as => 'add_invites'
  end

  resource :profile

  resources :contacts,           :except => [:update, :create] do
    get :sharing, :on => :collection
  end
  resources :aspect_memberships, :only   => [:destroy, :create, :update]
  resources :post_visibilities,  :only   => [:update]


  resources :people, :except => [:edit, :update] do
    resources :status_messages
    resources :photos
    get  :contacts
    collection do
      post 'by_handle' => :retrieve_remote, :as => 'person_by_handle'
      get :tag_index
    end
  end

  get "people/:id/aspect_membership_button" => "people#aspect_membership_dropdown", :as => "aspect_membership_button"




  # Federation

  controller :publics do
    get 'webfinger'             => :webfinger
    get 'hcard/users/:guid'     => :hcard
    get '.well-known/host-meta' => :host_meta
    post 'receive/users/:guid'  => :receive
    get 'hub'                   => :hub
  end


  # External


  get "/oauth/authorize" => "authorizations#new"
  post "/oauth/authorize" => "authorizations#create"

  post "/oauth/token" => "authorizations#token"
  resources :authorizations, :only => [:index, :destroy]

  resources :services, :only => [:index, :destroy]
  controller :services do
    match '/auth/:provider/callback' => :create
    match '/auth/failure'            => :failure
    scope 'services' do
      match 'inviter/:provider' => :inviter, :as => 'service_inviter'
      match 'finder/:provider'  => :finder,  :as => 'friend_finder'
    end
  end

  scope 'api/v0', :controller => :apis do
    get 'me' => :me
  end


  # Mobile site

  get 'mobile/toggle', :to => 'home#toggle_mobile', :as => 'toggle_mobile'


  # Startpage

  root :to => 'home#show'
end
