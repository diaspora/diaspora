#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

Diaspora::Application.routes.draw do
  resources :people,          :only   => [:index, :show, :destroy]
  resources :status_messages, :only   => [:create, :destroy, :show]
  resources :comments,        :except => [:index]
  resources :requests,        :except => [:edit, :update]
  resources :photos,          :except => [:index]
  resources :albums

  devise_for :users, :controllers => {:registrations => "registrations",
                                      :password      => "devise/passwords"}
  # added public route to user
  match 'public/:username', :to => 'users#public'
  resources :users,               :except => [:create, :new, :show]

  match 'aspects/move_friends', :to => 'aspects#move_friends', :as => 'move_friends'
  match 'aspects/move_friend',  :to => 'aspects#move_friend', :as => 'move_friend'
  match 'aspects/manage',       :to => 'aspects#manage'
  match 'aspects/public',       :to => 'aspects#public'
  resources :aspects,           :except => [:edit]

  match 'services/create',    :to   => "services#create"
  match 'services/destroy',   :to   => "services#destroy"
  match 'services/fb_post',   :to   => "services#fb_post"

  match 'warzombie',          :to   => "dev_utilities#warzombie"
  match 'zombiefriends',      :to   => "dev_utilities#zombiefriends"
  match 'zombiefriendaccept', :to   => "dev_utilities#zombiefriendaccept"
  match 'set_backer_number',  :to   => "dev_utilities#set_backer_number"
  match 'set_profile_photo',  :to   => "dev_utilities#set_profile_photo"
  #routes for devise, not really sure you will need to mess with this in the future, lets put default,
  #non mutable stuff in anohter file
  match 'login',  :to => 'devise/sessions#new',      :as => "new_user_session"
  match 'logout', :to => 'devise/sessions#destroy',  :as => "destroy_user_session"
  match 'signup', :to => 'registrations#new',        :as => "new_user_registration"

  match 'get_to_the_choppa', :to => redirect("/signup")
  #public routes
  #

  match 'webfinger', :to => 'publics#webfinger'
  match 'hcard/users/:id',    :to => 'publics#hcard'

  match 'hub',    :to => 'publics#hub'

  match '.well-known/host-meta',:to => 'publics#host_meta'
  match 'receive/users/:id',     :to => 'publics#receive'
  match 'log', :to => "dev_utilities#log"

  #root
  root :to => 'aspects#index'
end
