#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AspectsController do
  render_views

  before do
    @user    = Factory.create(:user)
    @aspect  = @user.aspect(:name => "lame-os")
    @aspect1 = @user.aspect(:name => "another aspect")
    @user2   = Factory.create(:user)
    @aspect2 = @user2.aspect(:name => "party people")
    friend_users(@user,@aspect, @user2, @aspect2)
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
        @user.aspects.count.should == 2
        post :create, "aspect" => {"name" => "new aspect"}
        @user.reload.aspects.count.should == 3
      end
      it "redirects to the aspect page" do
        post :create, "aspect" => {"name" => "new aspect"}
        response.should redirect_to(aspect_path(Aspect.find_by_name("new aspect")))
      end
    end
    describe "with invalid params" do
      it "does not create an aspect" do
        @user.aspects.count.should == 2
        post :create, "aspect" => {"name" => ""}
        @user.reload.aspects.count.should == 2
      end
      it "goes back to manage aspects" do
        post :create, "aspect" => {"name" => ""}
        response.should redirect_to(aspects_manage_path)
      end
    end
  end

  describe "#move_friend" do
    let(:opts) { {:friend_id => "person_id", :from => "from_aspect_id", :to => {:to => "to_aspect_id"}}}
    it 'calls the move_friend_method' do
      pending "need to figure out how to stub current_user to return our test @user"
      @user.should_receive(:move_friend).with( :friend_id => "person_id", :from => "from_aspect_id", :to => "to_aspect_id")
      post :move_friend, opts
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

  describe "#add_to_aspect" do
    it 'adds the users to the aspect' do
      @aspect1.reload
      @aspect1.people.include?(@user2.person).should be false
      post 'add_to_aspect', {:friend_id => @user2.person.id, :aspect_id => @aspect1.id }
      @aspect1.reload
      @aspect1.people.include?(@user2.person).should be true
    end
  end
end
