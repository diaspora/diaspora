#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PeopleController do
  render_views

  before do
    @user = alice
    @aspect = @user.aspects.first
    sign_in :user, @user
  end

  describe '#index (search)' do
    before do
      @eugene = Factory.create(:person,
        :profile => Factory.build(:profile, :first_name => "Eugene", :last_name => "w"))
      @korth = Factory.create(:person,
        :profile => Factory.build(:profile, :first_name => "Evan", :last_name => "Korth"))
    end

    it 'responds with json' do
      get :index, :q => "Korth", :format => 'json'
      response.body.should == [@korth].to_json
    end
    it 'does not set @hashes in a json request' do
      get :index, :q => "Korth", :format => 'json'
      assigns[:hashes].should be_nil
    end
    it 'sets @hashes in an html request' do
      get :index, :q => "Korth"
      assigns[:hashes].should_not be_nil
    end
    it "assigns people" do
      eugene2 = Factory.create(:person,
                               :profile => Factory.build(:profile, :first_name => "Eugene",
                                                         :last_name => "w"))
      get :index, :q => "Eug"
      assigns[:people].should =~ [@eugene, eugene2]
    end

    it "does not redirect to person page if there is exactly one match" do
      get :index, :q => "Korth"
      response.should_not redirect_to @korth
    end

    it "does not redirect if there are no matches" do
      get :index, :q => "Korthsauce"
      response.should_not be_redirect
    end

    it 'goes to a tag page if you search for a hash' do
      get :index, :q => '#babies'
      response.should redirect_to('/tags/babies')
    end
  end

  describe "#show performance", :performance => true do
    before do
      require 'benchmark'
      @posts = []
      @users = []
      8.times do |n|
        user = Factory.create(:user)
        @users << user
        aspect = user.aspects.create(:name => 'people')
        connect_users(@user, @user.aspects.first, user, aspect)

        @posts << @user.post(:status_message, :text => "hello#{n}", :to => aspect.id)
      end
      @posts.each do |post|
        @users.each do |user|
          user.comment "yo#{post.text}", :on => post
        end
      end
    end

    it 'takes time' do
      Benchmark.realtime {
        get :show, :id => @user.person.id
      }.should < 1.0
    end
  end

  describe '#show' do
    it "redirects to #index if the id is invalid" do
      get :show, :id => 'delicious'
      response.should redirect_to people_path
    end

    it "redirects to #index if no person is found" do
      get :show, :id => 3920397846
      response.should redirect_to people_path
    end

    it 'does not allow xss attacks' do
      user2 = bob
      profile = user2.profile
      profile.first_name = "<script> alert('xss attack');</script>"
      profile.save
      get :show, :id => user2.person.id
      response.should be_success
      response.body.match(profile.first_name).should be_false
    end

    context "when the person is the current user" do
      it "succeeds" do
        get :show, :id => @user.person.to_param
        response.should be_success
      end

      it "assigns the right person" do
        get :show, :id => @user.person.to_param
        assigns(:person).should == @user.person
      end

      it "assigns all the user's posts" do
        @user.posts.should be_empty
        @user.post(:status_message, :text => "to one aspect", :to => @aspect.id)
        @user.post(:status_message, :text => "to all aspects", :to => 'all')
        @user.post(:status_message, :text => "public", :to => 'all', :public => true)
        @user.reload.posts.length.should == 3
        get :show, :id => @user.person.to_param
        assigns(:posts).should =~ @user.posts
      end

      it "renders the comments on the user's posts" do
        message = @user.post :status_message, :text => 'test more', :to => @aspect.id
        @user.comment 'I mean it', :on => message
        get :show, :id => @user.person.id
        response.should be_success
      end
    end

    context "with no user signed in" do
      before do
        sign_out :user
        @person = bob.person
      end
      it "succeeds" do
        get :show, :id => @person.id
        response.status.should == 200
      end
      it "assigns only public posts" do
        public_posts = []
        public_posts << bob.post(:status_message, :text => "first public ", :to => bob.aspects[0].id, :public => true)
        bob.post(:status_message, :text => "to an aspect @user is not in", :to => bob.aspects[1].id)
        bob.post(:status_message, :text => "to all aspects", :to => 'all')
        public_posts << bob.post(:status_message, :text => "public", :to => 'all', :public => true)

        get :show, :id => @person.id

        assigns[:posts].should =~ public_posts
      end

      it 'throws 404 if the person is remote' do
        p = Factory(:person)

        get :show, :id => p.id
        response.status.should == 404
      end
    end
    context "when the person is a contact of the current user" do
      before do
        @person = bob.person
      end

      it "succeeds" do
        get :show, :id => @person.id
        response.should be_success
      end

      it "assigns only the posts the current user can see" do
        bob.posts.should be_empty
        posts_user_can_see = []
        posts_user_can_see << bob.post(:status_message, :text => "to an aspect @user is in", :to => bob.aspects[0].id)
        bob.post(:status_message, :text => "to an aspect @user is not in", :to => bob.aspects[1].id)
        posts_user_can_see << bob.post(:status_message, :text => "to all aspects", :to => 'all')
        posts_user_can_see << bob.post(:status_message, :text => "public", :to => 'all', :public => true)
        bob.reload.posts.length.should == 4

        get :show, :id => @person.id
        assigns(:posts).should =~ posts_user_can_see
      end
    end

    context "when the person is not a contact of the current user" do
      before do
        @person = eve.person
      end

      it "succeeds" do
        get :show, :id => @person.id
        response.should be_success
      end

      it "assigns only public posts" do
        eve.posts.should be_empty
        eve.post(:status_message, :text => "to an aspect @user is not in", :to => eve.aspects.first.id)
        eve.post(:status_message, :text => "to all aspects", :to => 'all')
        public_post = eve.post(:status_message, :text => "public", :to => 'all', :public => true)
        eve.reload.posts.length.should == 3

        get :show, :id => @person.id
        assigns[:posts].should =~ [public_post]
      end
    end
  end

  describe '#webfinger' do
    it 'enqueues a webfinger job' do
      Resque.should_receive(:enqueue).with(Job::SocketWebfinger, @user.id, @user.diaspora_handle, anything).once
      get :retrieve_remote, :diaspora_handle => @user.diaspora_handle
    end
  end
end
