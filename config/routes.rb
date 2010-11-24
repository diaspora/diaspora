#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

Diaspora::Application.routes.draw do
  resources :status_messages, :only   => [:create, :destroy, :show]
  resources :comments,        :except => [:index]
  resources :requests,        :except => [:edit, :update]
  resources :photos,          :except => [:index]
  resources :services

  resources :people
  resources :people do
    resources :status_messages
    resources :photos
  end
  match '/people/by_handle' => 'people#retrieve_remote', :as => 'person_by_handle'

  match '/auth/:provider/callback' => 'services#create'

  devise_for :users, :controllers => {:registrations => "registrations",
                                      :password      => "devise/passwords",
                                      :invitations   => "invitations"}
  # added public route to user
  match 'public/:username',          :to => 'users#public'
  match 'getting_started',           :to => 'users#getting_started', :as => 'getting_started'
  match 'users/export',              :to => 'users#export'
  match 'users/export_photos',       :to => 'users#export_photos'
  match 'login',                     :to => 'users#sign_up'
  resources :users,                  :except => [:create, :new, :show]

  match 'aspects/move_contact',  :to => 'aspects#move_contact', :as => 'move_contact'
  match 'aspects/add_to_aspect',:to => 'aspects#add_to_aspect', :as => 'add_to_aspect'
  match 'aspects/remove_from_aspect',:to => 'aspects#remove_from_aspect', :as => 'remove_from_aspect'
  match 'aspects/manage',       :to => 'aspects#manage'
  resources :aspects,           :except => [:edit]

  #match 'warzombie',          :to   => "dev_utilities#warzombie"
  #match 'zombiefriends',      :to   => "dev_utilities#zombiefriends"
  #match 'zombiefriendaccept', :to   => "dev_utilities#zombiefriendaccept"
  #match 'set_backer_number',  :to   => "dev_utilities#set_backer_number"
  #match 'set_profile_photo',  :to   => "dev_utilities#set_profile_photo"

  #public routes
  match 'webfinger',            :to => 'publics#webfinger'
  match 'hcard/users/:id',      :to => 'publics#hcard'
  match '.well-known/host-meta',:to => 'publics#host_meta'
  match 'receive/users/:id',    :to => 'publics#receive'
  match 'hub',                  :to => 'publics#hub'
  #match 'log',                  :to => "dev_utilities#log"


  #root
  root :to => 'home#show'
end
