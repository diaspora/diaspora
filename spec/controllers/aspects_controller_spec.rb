#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AspectsController do
  render_views

  before do
    @user                       = make_user
    @aspect                     = @user.aspects.create(:name => "lame-os")
    @aspect1                    = @user.aspects.create(:name => "another aspect")
    @user2                      = make_user
    @aspect2                    = @user2.aspects.create(:name => "party people")
    connect_users(@user, @aspect, @user2, @aspect2)
    @contact                    = @user.contact_for(@user2.person)
    sign_in :user, @user
    request.env["HTTP_REFERER"] = 'http://' + request.host
  end

  describe "#index" do
    it "assigns @contacts to all the user's contacts" do
      Factory.create :person
      get :index
      assigns[:contacts].should == @user.contacts
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

  describe "#manage" do
    it "succeeds" do
      get :manage
      response.should be_success
    end
    it "assigns aspect to manage" do
      get :manage
      assigns(:aspect).should == :manage
    end
    it "assigns remote_requests" do
      get :manage
      assigns(:remote_requests).should be_empty
    end
    context "when the user has pending requests" do
      before do
        requestor        = make_user
        requestor_aspect = requestor.aspects.create(:name => "Meh")
        requestor.send_contact_request_to(@user.person, requestor_aspect)

        requestor.reload
        requestor_aspect.reload
        @user.reload
      end
      it "succeeds" do
        get :manage
        response.should be_success
      end
      it "assigns aspect to manage" do
        get :manage
        assigns(:aspect).should == :manage
      end
      it "assigns remote_requests" do
        get :manage
        assigns(:remote_requests).count.should == 1
      end
    end
  end

  describe "#move_contact" do
    let(:opts) { {:person_id => "person_id", :from => "from_aspect_id", :to => {:to => "to_aspect_id"}} }
    it 'calls the move_contact_method' do
      pending "need to figure out what is the deal with remote requests"
      @controller.stub!(:current_user).and_return(@user)
      @user.should_receive(:move_contact).with(:person_id => "person_id", :from => "from_aspect_id", :to => "to_aspect_id")
      post :move_contact, opts
    end
  end

  describe "#update" do
    before do
      @aspect = @user.aspects.create(:name => "Bruisers")
    end
    it "doesn't overwrite random attributes" do
      new_user         = Factory.create :user
      params           = {"name" => "Bruisers"}
      params[:user_id] = new_user.id
      put('update', :id => @aspect.id, "aspect" => params)
      Aspect.find(@aspect.id).user_id.should == @user.id
    end
  end

  describe "#add_to_aspect" do
    it 'adds the users to the aspect' do
      @aspect1.reload
      @aspect1.people.include?(@contact).should be false
      post 'add_to_aspect', {:person_id => @user2.person.id, :aspect_id => @aspect1.id}
      @aspect1.reload
      @aspect1.people.include?(@contact).should be true
    end
  end

  describe "#remove_from_aspect" do
    it 'adds the users to the aspect' do
      @aspect.reload
      @aspect.people.include?(@contact).should be true
      post 'remove_from_aspect', {:person_id => @user2.person.id, :aspect_id => @aspect1.id}
      @aspect1.reload
      @aspect1.people.include?(@contact).should be false
    end
  end
end
