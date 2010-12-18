#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

Diaspora::Application.routes.draw do
  resources :status_messages, :only => [:create, :destroy, :show]
  resources :comments,        :only => [:create]
  resources :requests,        :only => [:destroy, :create]
  resources :services
  
  resources :notifications
  resources :posts,           :only => [:show], :path => '/p/'



  match '/people/share_with' => 'people#share_with', :as => 'share_with'
  resources :people do
    resources :status_messages
    resources :photos
  end

  match '/people/by_handle' => 'people#retrieve_remote', :as => 'person_by_handle'
  match '/auth/:provider/callback' => 'services#create'
  match '/auth/failure' => 'services#failure'

  match 'photos/make_profile_photo' => 'photos#make_profile_photo'
  resources :photos, :except => [:index]

  devise_for :users, :controllers => {:registrations => "registrations",
                                      :password      => "devise/passwords",
                                      :invitations   => "invitations"}
  # added public route to user
  match 'public/:username',          :to => 'users#public'
  match 'getting_started',           :to => 'users#getting_started', :as => 'getting_started'
  match 'getting_started_completed', :to => 'users#getting_started_completed'
  match 'users/export',              :to => 'users#export'
  match 'users/export_photos',       :to => 'users#export_photos'
  match 'login',                     :to => 'users#sign_up'
  resources :users,                  :except => [:create, :new, :show]

  match 'aspects/move_contact',      :to => 'aspects#move_contact', :as => 'move_contact'
  match 'aspects/add_to_aspect',     :to => 'aspects#add_to_aspect', :as => 'add_to_aspect'
  match 'aspects/remove_from_aspect',:to => 'aspects#remove_from_aspect', :as => 'remove_from_aspect'
  match 'aspects/manage',            :to => 'aspects#manage'
  resources :aspects,                :except => [:edit]

  #public routes
  match 'webfinger',            :to => 'publics#webfinger'
  match 'hcard/users/:id',      :to => 'publics#hcard'
  match '.well-known/host-meta',:to => 'publics#host_meta'
  match 'receive/users/:id',    :to => 'publics#receive'
  match 'hub',                  :to => 'publics#hub'

  #root
  root :to => 'home#show'
end
