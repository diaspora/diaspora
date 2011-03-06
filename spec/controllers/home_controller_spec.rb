#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, "spec", "shared_behaviors", "log_override")

describe HomeController do
  render_views

  before do
    @user = alice
    sign_in @user
    sign_out @user
  end

  describe '#show' do
    it 'shows a login link if no user is not logged in' do
      get :show
      response.body.should include("login")
    end

    it 'redirects to aspects index if user is logged in' do
      sign_in @user
      get :show, :home => true
      response.should redirect_to( :controller => 'aspects', :action => 'index')
    end

    it 'redirects to aspects index with stored aspects' do
      sign_in @user
      @aspect0 = @user.aspects.all[0]
      @aspect1 = @user.aspects.create(:name => "Yeaaaah!")
      @index_params = {:a_ids => [@aspect0.id.to_s, @aspect1.id.to_s]}
      @user.aspects.where(:id => @index_params[:a_ids]).update_all(:open => true)
      @user.save
      get :show
      response.should redirect_to( :controller => 'aspects', :action => 'index', :a_ids => @index_params[:a_ids] )
    end
  end

  describe "custom logging on success" do
    before do
      @action = :show
      @action_params = {"lasers" => "green"}
    end
    it_should_behave_like "it overrides the logs on success"
  end

  describe "custom logging on redirect" do
    before do
      sign_in :user, bob
      @action = :show
      @action_params = {"lasers" => "green"}
    end
    it_should_behave_like "it overrides the logs on redirect"
  end
end
