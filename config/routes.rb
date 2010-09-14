#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



Diaspora::Application.routes.draw do
  resources :people, :only => [:index, :show, :destroy]
  resources :users, :except => [:create, :new]
  resources :status_messages, :only => [:create, :destroy, :show]
  resources :comments, :except => [:index]
  resources :requests, :except => [:edit, :update]
  resources :photos, :except => [:index]
  resources :albums

  match 'aspects/manage', :to => 'aspects#manage'
  resources :aspects, :except => [:edit]
  match 'aspects/move_friends', :to => 'aspects#move_friends', :as => 'move_friends'
  match 'aspects/move_friend', :to => 'aspects#move_friend', :as => 'move_friend'

  match 'warzombie',          :to => "dev_utilities#warzombie"
  match 'zombiefriends',      :to => "dev_utilities#zombiefriends"
  match 'zombiefriendaccept', :to => "dev_utilities#zombiefriendaccept"
  match 'set_backer_number', :to => "dev_utilities#set_backer_number"
  match 'set_profile_photo', :to => "dev_utilities#set_profile_photo"

  #routes for devise, not really sure you will need to mess with this in the future, lets put default,
  #non mutable stuff in anohter file
  devise_for :users
  match 'login',  :to => 'devise/sessions#new',      :as => "new_user_session"
  match 'logout', :to => 'devise/sessions#destroy',  :as => "destroy_user_session"
  match 'get_to_the_choppa', :to => 'devise/registrations#new', :as => "new_user_registration"

  #public routes
  #
  match 'webfinger', :to => 'publics#webfinger'
  match 'hcard/users/:id',    :to => 'publics#hcard'

  match '.well-known/host-meta',:to => 'publics#host_meta'        
  match 'receive/users/:id',     :to => 'publics#receive'    
  match 'log', :to => "dev_utilities#log"

  #root
  root :to => 'aspects#index'
end
