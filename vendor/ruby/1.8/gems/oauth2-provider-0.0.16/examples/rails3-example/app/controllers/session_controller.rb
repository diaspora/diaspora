class SessionController < ApplicationController
  class Session
    attr_accessor :login, :password
  end

  def new
    @session = Session.new
  end

  def create
    if account = Account.authenticate(params[:session][:login], params[:session][:password])
      session[:account_id] = account.id
      redirect_to return_url
    else
      redirect_to :action => :new
    end
  end

  private

  def return_url
    session[:return_url] || root_url
  end
end