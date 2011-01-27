#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, "spec", "shared_behaviors", "log_override")

describe AspectsController do
  render_views

  before do
    @user  = alice
    @user2 = bob

    @aspect0  = @user.aspects.first
    @aspect1  = @user.aspects.create(:name => "another aspect")
    @aspect2  = @user2.aspects.first

    @contact = @user.contact_for(@user2.person)
    @user.getting_started = false
    @user.save
    sign_in :user, @user
    @controller.stub(:current_user).and_return(@user)
    request.env["HTTP_REFERER"] = 'http://' + request.host
  end

  describe "custom logging on success" do
    before do
      @action = :index
    end
    it_should_behave_like "it overrides the logs on success"
  end

  describe "custom logging on error" do
    class FakeError < RuntimeError; attr_accessor :original_exception; end
    before do
      @action = :index
      @desired_error_message = "I love errors"
      @error = FakeError.new(@desired_error_message)
      @orig_error_message = "I loooooove nested errors!"
      @error.original_exception = NoMethodError.new(@orig_error_message)
      @controller.stub(:index).and_raise(@error)
    end
    it_should_behave_like "it overrides the logs on error"
  end

  describe "custom logging on redirect" do
    before do
      @action = :show
      @action_params = {'id' => @aspect0.id.to_s}
    end
    it_should_behave_like "it overrides the logs on redirect"
  end

  describe "#index" do
    it "assigns @contacts to all the user's contacts" do
      get :index
      assigns[:contacts].map{|c| c.id}.should == @user.contacts.map{|c| c.id}
    end

    context 'filtering' do
      before do
        @posts = []
        @users = []
        8.times do |n|
          user = Factory(:user)
          @users << user
          aspect = user.aspects.create(:name => 'people')
          connect_users(@user, @aspect0, user, aspect)
          post =  @user.post(:status_message, :message => "hello#{n}", :to => eval("@aspect#{(n%2)}.id"))
          @posts << post
        end
      end

      it "returns all posts" do
        @user.aspects.reload
        get :index
        assigns(:posts).length.should == 8
      end

      it "returns posts filtered by a single aspect" do
        get :index, :a_ids => [@aspect1.id.to_s]
        assigns(:posts).length.should == 4
      end

      it "returns posts from filtered aspects" do
        get :index, :a_ids => [@aspect0.id.to_s, @aspect1.id.to_s]
        assigns(:posts).length.should == 8
      end
    end

    context 'performance' do
      before do
        require 'benchmark'
        @posts = []
        @users = []
        8.times do |n|
          user = Factory.create(:user)
          @users << user
          aspect = user.aspects.create(:name => 'people')
          connect_users(@user, @aspect0, user, aspect)
          post =  @user.post(:status_message, :message => "hello#{n}", :to => @aspect1.id)
          @posts << post
          8.times do |n|
            user.comment "yo#{post.message}", :on => post
          end
        end
      end

      it 'takes time' do
        Benchmark.realtime{
          get :index
        }.should < 1.5
      end
    end
  end

  describe "#show" do
    it "succeeds" do
      get :show, 'id' => @aspect0.id.to_s
      response.should be_redirect
    end
    it 'redirects on an invalid id' do
      get :show, 'id' => 4341029835
      response.should be_redirect
    end
  end

  describe "#create" do
    context "with valid params" do
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
    context "with invalid params" do
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
    it "performs reasonably" do
        require 'benchmark'
        8.times do |n|
          aspect = @user.aspects.create(:name => "aspect#{n}")
          8.times do |o|
            person = Factory(:person)
            @user.activate_contact(person, aspect)
          end
        end
        Benchmark.realtime{
          get :manage
        }.should < 4.5
    end
    it "assigns aspect to manage" do
      get :manage
      assigns(:aspect).should == :manage
    end
    it "assigns remote_requests" do
      get :manage
      assigns(:remote_requests).should be_empty
    end
    it "assigns contacts to only non-pending" do
      @user.contacts.count.should == 1
      @user.send_contact_request_to(Factory(:user).person, @aspect0)
      @user.contacts.count.should == 2

      get :manage
      contacts = assigns(:contacts)
      contacts.count.should == 1
      contacts.first.should == @contact
    end
    context "when the user has pending requests" do
      before do
        requestor        = Factory.create(:user)
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
      it "generates a jasmine fixture" do
        get :manage
        save_fixture(html_for("body"), "aspects_manage")
      end
    end
  end

  describe "#move_contact" do
    before do
      @person = Factory.create(:person)
      @opts = {
        :person_id => @person.id,
        :from => @aspect0.id,
        :to =>
        {:to => @aspect1.id}
      }
    end
    it 'calls the move_contact_method' do
      @controller.stub!(:current_user).and_return(@user)
      @user.should_receive(:move_contact)
      post "move_contact", @opts
    end
  end


  describe "#update" do
    before do
      @aspect0 = @user.aspects.create(:name => "Bruisers")
    end
    it "doesn't overwrite random attributes" do
      new_user         = Factory.create :user
      params           = {"name" => "Bruisers"}
      params[:user_id] = new_user.id
      put('update', :id => @aspect0.id, "aspect" => params)
      Aspect.find(@aspect0.id).user_id.should == @user.id
    end
  end

  describe "#add_to_aspect" do
    context 'with an incoming request' do
      before do
        @user3 = Factory.create(:user)
        @user3.send_contact_request_to(@user.person, @user3.aspects.create(:name => "Walruses"))
      end
      it 'deletes the request' do
        post 'add_to_aspect',
          :format => 'js',
          :person_id => @user3.person.id,
          :aspect_id => @aspect1.id
        Request.where(:sender_id => @user3.person.id, :recipient_id => @user.person.id).first.should be_nil
      end
      it 'does not leave the contact pending' do
        post 'add_to_aspect',
          :format => 'js',
          :person_id => @user3.person.id,
          :aspect_id => @aspect1.id
        @user.contact_for(@user3.person).should_not be_pending
      end
    end
    context 'with a non-contact' do
      before do
        @person = Factory(:person)
      end
      it 'calls send_contact_request_to' do
        @user.should_receive(:send_contact_request_to).with(@person, @aspect1)
        post 'add_to_aspect',
          :format => 'js',
          :person_id => @person.id,
          :aspect_id => @aspect1.id
      end
      it 'does not call add_contact_to_aspect' do
        @user.should_not_receive(:add_contact_to_aspect)
        post 'add_to_aspect',
          :format => 'js',
          :person_id => @person.id,
          :aspect_id => @aspect1.id
      end
    end
    it 'adds the users to the aspect' do
      @user.should_receive(:add_contact_to_aspect)
      post 'add_to_aspect',
        :format => 'js',
        :person_id => @user2.person.id,
        :aspect_id => @aspect1.id
      response.should be_success
    end
  end

  describe '#edit' do
    it 'renders' do
      get :edit, :id => @aspect0.id
      response.should be_success
    end
  end

  describe "#remove_from_aspect" do
    it 'removes contacts from an aspect' do
      @user.add_contact_to_aspect(@contact, @aspect1)
      post 'remove_from_aspect',
        :format => 'js',
        :person_id => @user2.person.id,
        :aspect_id => @aspect0.id
      response.should be_success
      @aspect0.reload
      @aspect0.contacts.include?(@contact).should be false
    end
  end

  describe "#hashes_for_posts" do
    it 'returns only distinct people' do
    end
  end
end
