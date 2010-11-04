#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

Diaspora::Application.routes.draw do
  resources :people
  resources :status_messages, :only   => [:create, :destroy, :show]
  resources :comments,        :except => [:index]
  resources :requests,        :except => [:edit, :update]
  resources :photos
  resources :services

  match '/auth/:provider/callback' => 'services#create'

  devise_for :users, :controllers => {:registrations => "registrations",
                                      :password      => "devise/passwords",
                                      :invitations   => "invitations"}
  # added public route to user
  match 'public/:username',          :to => 'users#public'
  match 'getting_started',           :to => 'users#getting_started', :as => 'getting_started'
  match 'users/export',              :to => 'users#export'
  match 'users/export_photos',       :to => 'users#export_photos'
  resources :users,                  :except => [:create, :new, :show]

  match 'aspects/move_friend',  :to => 'aspects#move_friend', :as => 'move_friend'
  match 'aspects/add_to_aspect',:to => 'aspects#add_to_aspect', :as => 'add_to_aspect'
  match 'aspects/remove_from_aspect',:to => 'aspects#remove_from_aspect', :as => 'remove_from_aspect'
  match 'aspects/manage',       :to => 'aspects#manage'
  resources :aspects,           :except => [:edit]

  match 'warzombie',          :to   => "dev_utilities#warzombie"
  match 'zombiefriends',      :to   => "dev_utilities#zombiefriends"
  match 'zombiefriendaccept', :to   => "dev_utilities#zombiefriendaccept"
  match 'set_backer_number',  :to   => "dev_utilities#set_backer_number"
  match 'set_profile_photo',  :to   => "dev_utilities#set_profile_photo"

  #signup
  match 'get_to_the_choppa', :to => redirect("/users/sign_up")

  #public routes
  match 'webfinger',            :to => 'publics#webfinger'
  match 'hcard/users/:id',      :to => 'publics#hcard'
  match '.well-known/host-meta',:to => 'publics#host_meta'
  match 'receive/users/:id',    :to => 'publics#receive'
  match 'hub',                  :to => 'publics#hub'
  match 'log',                  :to => "dev_utilities#log"

  #root
  root :to => 'aspects#index'
end
