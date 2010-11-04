#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AspectsController do
  render_views

  before do
    @user    = make_user
    @aspect  = @user.aspects.create(:name => "lame-os")
    @aspect1 = @user.aspects.create(:name => "another aspect")
    @user2   = make_user
    @aspect2 = @user2.aspects.create(:name => "party people")
    friend_users(@user,@aspect, @user2, @aspect2)
    @contact = @user.contact_for(@user2.person)
    sign_in :user, @user
    request.env["HTTP_REFERER"] = 'http://' + request.host
  end

  describe "#index" do
    it "assigns @friends to all the user's friends" do
      Factory.create :person
      get :index
      assigns[:friends].should == @user.person_objects
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
      it "goes back to the page you came from" do
        post :create, "aspect" => {"name" => ""}
        response.should redirect_to(:back)
      end
    end
  end

  describe "#move_friend" do
    let(:opts) { {:friend_id => "person_id", :from => "from_aspect_id", :to => {:to => "to_aspect_id"}}}
    it 'calls the move_friend_method' do
      pending "need to figure out what is the deal with remote requests" 
      @controller.stub!(:current_user).and_return(@user)
      @user.should_receive(:move_friend).with( :friend_id => "person_id", :from => "from_aspect_id", :to => "to_aspect_id")
      post :move_friend, opts
    end
  end

  describe "#update" do
    before do
      @aspect = @user.aspects.create(:name => "Bruisers")
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
      @aspect1.people.include?(@contact).should be false
      post 'add_to_aspect', {:friend_id => @user2.person.id, :aspect_id => @aspect1.id }
      @aspect1.reload
      @aspect1.people.include?(@contact).should be true
    end
  end 
  
  describe "#remove_from_aspect" do
    it 'adds the users to the aspect' do
      @aspect.reload
      @aspect.people.include?(@contact).should be true
      post 'remove_from_aspect', {:friend_id => @user2.person.id, :aspect_id => @aspect1.id }
      @aspect1.reload
      @aspect1.people.include?(@contact).should be false
    end
  end
end
