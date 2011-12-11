#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PeopleController do
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
      assigns[:people].map{|x| x.id}.should =~ [@eugene.id, eugene2.id]
    end

    it "excludes people that are not searchable" do
      eugene2 = Factory.create(:person,
                               :profile => Factory.build(:profile, :first_name => "Eugene",
                                                         :last_name => "w", :searchable => false))
      get :index, :q => "Eug"
      assigns[:people].should_not =~ [eugene2]
    end

    it "allows unsearchable people to be found by handle" do
      eugene2 = Factory.create(:person, :diaspora_handle => "eugene@example.org",
                               :profile => Factory.build(:profile, :first_name => "Eugene",
                                                         :last_name => "w", :searchable => false))
      get :index, :q => "eugene@example.org"
      assigns[:people][0].id.should == eugene2.id
    end

    it "allows unsearchable people to be found by handle" do
      d_id = "eugene@example.org"
      @controller.should_receive(:diaspora_id?).with(d_id)
      get :index, :q => d_id
    end

     it "downcases the handle before trying to find someone by it" do
      eugene2 = Factory.create(:person, :diaspora_handle => "eugene@example.org",
                               :profile => Factory.build(:profile, :first_name => "Eugene",
                                                         :last_name => "w", :searchable => false))
      get :index, :q => "Eugene@Example.ORG"
      assigns[:people][0].id.should == eugene2.id
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
      response.should redirect_to(tag_path('babies', :q => '#babies'))
    end

    it 'goes to a tag page if you search for a hash with dots' do
      get :index, :q => '#babi.es'
      response.should redirect_to(tag_path('babies', :q => '#babi.es'))
    end

    it 'stay on the page if you search for the empty hash' do
      get :index, :q => '#'
      flash[:error].should be_present
    end

    it 'does not fails if you search for the empty term' do
      get :index, :q => ''
      response.should be_success
    end
  end

  describe '#tag_index' do
    it 'works for js' do
      get :tag_index, :name => 'jellybeans', :format => :js
      response.should be_success
    end

    it 'returns awesome people who have that tag' do
      f = Factory(:person)
      f.profile.tag_string = "#seeded"
      f.profile.save
      get :tag_index, :name => 'seeded', :format => :js
      assigns[:people].count.should == 1
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
          user.comment "yo#{post.text}", :post => post
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
    it "404s if the id is invalid" do
      get :show, :id => 'delicious'
      response.code.should == "404"
    end

    it "404s if no person is found via id" do
      get :show, :id => 3920397846
      response.code.should == "404"
    end

    it "404s if no person is found via username" do
      get :show, :username => 'delicious'
      response.code.should == "404"
    end

    it 'redirects home for closed account' do
      @person = Factory.create(:person, :closed_account => true)
      get :show, :id => @person.id
      response.should be_redirect
      flash[:notice].should_not be_blank
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

      it 'succeeds on the mobile site' do
        get :show, :id => @user.person.to_param, :format => :mobile
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
        assigns(:stream).posts.map(&:id).should =~ @user.posts.map(&:id)
      end

      it "renders the comments on the user's posts" do
        message = @user.post :status_message, :text => 'test more', :to => @aspect.id
        @user.comment 'I mean it', :post => message
        get :show, :id => @user.person.id
        response.should be_success
      end

      it 'passes through the includes option for json requests' do
        json = @user.person.as_json
        Person.any_instance.should_receive(:as_json).with(:includes => "horses").and_return(json)
        get :show, :format => :json, :id => @user.person.id, :includes => "horses"
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

      it 'succeeds on the mobile site' do
        get :show, :id => @person.id, :format => :mobile
        response.should be_success
      end

      context 'with posts' do
        before do
          @public_posts = []
          @public_posts << bob.post(:status_message, :text => "first public ", :to => bob.aspects[0].id, :public => true)
          bob.post(:status_message, :text => "to an aspect @user is not in", :to => bob.aspects[1].id)
          bob.post(:status_message, :text => "to all aspects", :to => 'all')
          @public_posts << bob.post(:status_message, :text => "public", :to => 'all', :public => true)
          @public_posts.first.created_at -= 1000
          @public_posts.first.save
        end

        it "posts include reshares" do
          reshare = @user.post(:reshare, :public => true, :root_guid => Factory(:status_message, :public => true).guid, :to => alice.aspects)
          get :show, :id => @user.person.id
          assigns[:stream].posts.map{|x| x.id}.should include(reshare.id)
        end

        it "assigns only public posts" do
          get :show, :id => @person.id
          assigns[:stream].posts.map(&:id).should =~ @public_posts.map(&:id)
        end

        it 'is sorted by created_at desc' do
          get :show, :id => @person.id
          assigns[:stream].stream_posts.should == @public_posts.sort_by{|p| p.created_at}.reverse
        end
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

      it 'succeeds on the mobile site' do
        get :show, :id => @person.id, :format => :mobile
        response.should be_success
      end

      it "assigns only the posts the current user can see" do
        bob.posts.should be_empty
        posts_user_can_see = []
        aspect_user_is_in = bob.aspects.where(:name => "generic").first
        aspect_user_is_not_in = bob.aspects.where(:name => "empty").first
        posts_user_can_see << bob.post(:status_message, :text => "to an aspect @user is in", :to => aspect_user_is_in.id)
        bob.post(:status_message, :text => "to an aspect @user is not in", :to => aspect_user_is_not_in.id)
        posts_user_can_see << bob.post(:status_message, :text => "to all aspects", :to => 'all')
        posts_user_can_see << bob.post(:status_message, :text => "public", :to => 'all', :public => true)
        bob.reload.posts.length.should == 4

        get :show, :id => @person.id
        assigns(:stream).posts.map(&:id).should =~ posts_user_can_see.map(&:id)
      end

      it "posts include reshares" do
        reshare = @user.post(:reshare, :public => true, :root_guid => Factory(:status_message, :public => true).guid, :to => alice.aspects)
        get :show, :id => @user.person.id
        assigns[:stream].posts.map{|x| x.id}.should include(reshare.id)
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

      it 'succeeds on the mobile site' do
        get :show, :id => @person.id, :format => :mobile
        response.should be_success
      end

      it "assigns only public posts" do
        eve.posts.should be_empty
        eve.post(:status_message, :text => "to an aspect @user is not in", :to => eve.aspects.first.id)
        eve.post(:status_message, :text => "to all aspects", :to => 'all')
        public_post = eve.post(:status_message, :text => "public", :to => 'all', :public => true)
        eve.reload.posts.length.should == 3

        get :show, :id => @person.id
        assigns[:stream].posts.map(&:id).should =~ [public_post].map(&:id)
      end

      it "posts include reshares" do
        reshare = @user.post(:reshare, :public => true, :root_guid => Factory(:status_message, :public => true).guid, :to => alice.aspects)
        get :show, :id => @user.person.id
        assigns[:stream].posts.map{|x| x.id}.should include(reshare.id)
      end
    end
  end

  describe '#contacts' do
    it 'assigns the contacts of a person' do
      contact = alice.contact_for(bob.person)
      contacts = contact.contacts
      get :contacts, :person_id => bob.person.id
      assigns(:contacts_of_contact).should =~ contacts
      response.should be_success
    end

    it 'shows an error when invalid person id' do
      get :contacts, :person_id => 'foo'
      flash[:error].should be_present
      response.should redirect_to people_path
    end
  end

  describe '#diaspora_id?' do
    it 'returns true for pods on urls' do
      @controller.diaspora_id?("ilya_123@pod.geraspora.de").should be_true
    end

    it 'returns true for pods on urls with port' do
      @controller.diaspora_id?("ilya_123@pod.geraspora.de:12314").should be_true
    end

    it 'returns true for pods on localhost' do
      @controller.diaspora_id?("ilya_123@localhost").should be_true
    end

    it 'returns true for pods on localhost and port' do
      @controller.diaspora_id?("ilya_123@localhost:1234").should be_true
    end

    it 'returns true for pods on ip' do
      @controller.diaspora_id?("ilya_123@1.1.1.1").should be_true
    end

    it 'returns true for pods on ip and port' do
      @controller.diaspora_id?("ilya_123@1.2.3.4:1234").should be_true
    end

    it 'returns false for pods on with invalid url characters' do
      @controller.diaspora_id?("ilya_123@join_diaspora.com").should be_false
    end

    it 'returns false for invalid usernames' do
      @controller.diaspora_id?("ilya_2%3@joindiaspora.com").should be_false
    end
  end

  describe '#webfinger' do
    it 'enqueues a webfinger job' do
      Resque.should_receive(:enqueue).with(Jobs::SocketWebfinger, @user.id, @user.diaspora_handle, anything).once
      get :retrieve_remote, :diaspora_handle => @user.diaspora_handle
    end
  end
end
