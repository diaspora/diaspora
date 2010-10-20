#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AspectsController do
  render_views

  before do
    @user = Factory.create(:user)
    @user.aspect(:name => "lame-os")
    @person = Factory.create(:person)
    sign_in :user, @user
  end

  describe "#index" do
    it "assigns @friends to all the user's friends" do
      Factory.create :person
      get :index
      assigns[:friends].should == @user.friends
    end
  end

  describe "#create" do
    describe "with valid params" do
      it "creates an aspect" do
        @user.aspects.count.should == 1
        post :create, "aspect" => {"name" => "new aspect"}
        @user.reload.aspects.count.should == 2
      end
      it "redirects to the aspect page" do
        post :create, "aspect" => {"name" => "new aspect"}
        response.should redirect_to(aspect_path(Aspect.find_by_name("new aspect")))
      end
    end
    describe "with invalid params" do
      it "does not create an aspect" do
        @user.aspects.count.should == 1
        post :create, "aspect" => {"name" => ""}
        @user.reload.aspects.count.should == 1
      end
      it "goes back to manage aspects" do
        post :create, "aspect" => {"name" => ""}
        response.should redirect_to(aspects_manage_path)
      end
    end
  end

  describe "#update" do
    before do
      @aspect = @user.aspect(:name => "Bruisers")
    end
    it "doesn't overwrite random attributes" do
      new_user = Factory.create :user
      params = {"name" => "Bruisers"}
      params[:user_id] = new_user.id
      put('update', :id => @aspect.id, "aspect" => params)
      Aspect.find(@aspect.id).user_id.should == @user.id
    end
  end
end
