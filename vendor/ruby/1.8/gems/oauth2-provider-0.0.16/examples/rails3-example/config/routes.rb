Rails3Example::Application.routes.draw do
  resource :session, :controller => :session
  resource :account, :controller => :account

  match "/oauth/authorize", :via => :get, :to => "authorization#new"
  match "/oauth/authorize", :via => :post, :to => "authorization#create"

  root :to => 'home#show'
end
