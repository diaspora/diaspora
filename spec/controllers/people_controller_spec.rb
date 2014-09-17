#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PeopleController, :type => :controller do
  before do
    @user = alice
    @aspect = @user.aspects.first
    sign_in :user, @user
  end

  describe '#index (search)' do
    before do
      @eugene = FactoryGirl.create(:person,
                        :profile => FactoryGirl.build(:profile, :first_name => "Eugene", :last_name => "w"))
      @korth = FactoryGirl.create(:person,
                       :profile => FactoryGirl.build(:profile, :first_name => "Evan", :last_name => "Korth"))
    end

    describe 'via json' do
      it 'succeeds' do
        get :index, :q => "Korth", :format => 'json'
        expect(response).to be_success
      end

      it 'responds with json' do
        get :index, :q => "Korth", :format => 'json'
        expect(response.body).to eq([@korth].to_json)
      end

      it 'does not assign hashes' do
        get :index, :q => "Korth", :format => 'json'
        expect(assigns[:hashes]).to be_nil
      end
    end

    describe 'via html' do
      context 'query is a diaspora ID' do
        before do
          @unsearchable_eugene = FactoryGirl.create(:person, :diaspora_handle => "eugene@example.org",
                                         :profile => FactoryGirl.build(:profile, :first_name => "Eugene",
                                                                   :last_name => "w", :searchable => false))
        end
        it 'finds people even if they have searchable off' do
          get :index, :q => "eugene@example.org"
          expect(assigns[:people][0].id).to eq(@unsearchable_eugene.id)
        end

        it 'downcases the query term' do
          get :index, :q => "Eugene@Example.ORG"
          expect(assigns[:people][0].id).to eq(@unsearchable_eugene.id)
        end

        it 'does not the background query task if the user is found' do
          get :index, :q => "Eugene@Example.ORG"
          expect(assigns[:background_query]).to eq(nil)
        end

        it 'sets background query task if the user is not found' do
          get :index, :q => "Eugene@Example1.ORG"
          expect(assigns[:background_query]).to eq("eugene@example1.org")
        end
      end

      context 'query is not a tag or a diaspora ID' do
        it 'assigns hashes' do
          get :index, :q => "Korth"
          expect(assigns[:hashes]).not_to be_nil
        end

        it 'does not set the background query task' do
          get :index, :q => "Korth"
          expect(assigns[:background_query]).not_to be_present
        end

        it "assigns people" do
          eugene2 = FactoryGirl.create(:person,
                            :profile => FactoryGirl.build(:profile, :first_name => "Eugene",
                                                      :last_name => "w"))
          get :index, :q => "Eug"
          expect(assigns[:people].map { |x| x.id }).to match_array([@eugene.id, eugene2.id])
        end

        it "succeeds if there is exactly one match" do
          get :index, :q => "Korth"
          expect(assigns[:people].length).to eq(1)
          expect(response).to be_success
        end

        it "succeeds if there are no matches" do
          get :index, :q => "Korthsauce"
          expect(assigns[:people].length).to eq(0)
          expect(response).to be_success
        end

        it 'succeeds if you search for the empty term' do
          get :index, :q => ''
          expect(response).to be_success
        end

        it 'succeeds if you search for punctuation' do
          get :index, :q => '+'
          expect(response).to be_success
        end

        it "excludes people who have searchable off" do
          eugene2 = FactoryGirl.create(:person,
                            :profile => FactoryGirl.build(:profile, :first_name => "Eugene",
                                                      :last_name => "w", :searchable => false))
          get :index, :q => "Eug"
          expect(assigns[:people]).not_to match_array([eugene2])
        end
      end
    end
  end

  describe '#tag_index' do
    it 'works for js' do
      xhr :get, :tag_index, :name => 'jellybeans', :format => :js
      expect(response).to be_success
    end

    it 'returns awesome people who have that tag' do
      f = FactoryGirl.create(:person)
      f.profile.tag_string = "#seeded"
      f.profile.save
      xhr :get, :tag_index, :name => 'seeded', :format => :js
      expect(assigns[:people].count).to eq(1)
    end
  end

  describe "#show performance", :performance => true do
    before do
      require 'benchmark'
      @posts = []
      @users = []
      8.times do |n|
        user = FactoryGirl.create(:user)
        @users << user
        aspect = user.aspects.create(:name => 'people')
        connect_users(@user, @user.aspects.first, user, aspect)

        @posts << @user.post(:status_message, :text => "hello#{n}", :to => aspect.id)
      end
      @posts.each do |post|
        @users.each do |user|
          user.comment!(post, "yo#{post.text}")
        end
      end
    end

    it 'takes time' do
      expect(Benchmark.realtime {
        get :show, :id => @user.person.to_param
      }).to be < 1.0
    end
  end

  describe '#show' do
    it "404s if the id is invalid" do
      get :show, :id => 'delicious'
      expect(response.code).to eq("404")
    end

    it "404s if no person is found via id" do
      get :show, :id => "3d920397846"
      expect(response.code).to eq("404")
    end

    it "404s if no person is found via username" do
      get :show, :username => 'delicious'
      expect(response.code).to eq("404")
    end

    it 'finds a person via username' do
      get :show, username: @user.username
      expect(assigns(:person)).to eq(@user.person)
    end

    it 'redirects home for closed account' do
      @person = FactoryGirl.create(:person, :closed_account => true)
      get :show, :id => @person.to_param
      expect(response).to be_redirect
      expect(flash[:notice]).not_to be_blank
    end

    it 'does not allow xss attacks' do
      user2 = bob
      profile = user2.profile
      profile.update_attribute(:first_name, "</script><script> alert('xss attack');</script>")
      get :show, :id => user2.person.to_param
      expect(response).to be_success
      expect(response.body).not_to include(profile.first_name)
    end

    it "doesn't leak photos in the sidebar" do
      private_photo = @user.post(:photo, user_file: uploaded_photo, to: @aspect.id, public: false)
      public_photo = @user.post(:photo, user_file: uploaded_photo, to: @aspect.id, public: true)
      allow(@user.person).to receive(:remote?) { false }

      sign_out :user
      get :show, id: @user.person.to_param

      expect(response).to be_success
      expect(assigns(:photos)).not_to include private_photo
      expect(assigns(:photos)).to include public_photo
    end

    context "when the person is the current user" do
      it "succeeds" do
        get :show, :id => @user.person.to_param
        expect(response).to be_success
      end

      it 'succeeds on the mobile site' do
        get :show, :id => @user.person.to_param, :format => :mobile
        expect(response).to be_success
      end

      it "assigns the right person" do
        get :show, :id => @user.person.to_param
        expect(assigns(:person)).to eq(@user.person)
      end
    end

    context "with no user signed in" do
      before do
        sign_out :user
        @person = bob.person
      end

      it "succeeds" do
        get :show, :id => @person.to_param
        expect(response.status).to eq(200)
      end

      it 'succeeds on the mobile site' do
        get :show, :id => @person.to_param, :format => :mobile
        expect(response).to be_success
      end

      it 'forces to sign in if the person is remote' do
        p = FactoryGirl.create(:person)

        get :show, :id => p.to_param
        expect(response).to be_redirect
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "when the person is a contact of the current user" do
      before do
        @person = bob.person
      end

      it "succeeds" do
        get :show, :id => @person.to_param
        expect(response).to be_success
      end

      it 'succeeds on the mobile site' do
        get :show, :id => @person.to_param, :format => :mobile
        expect(response).to be_success
      end

      it 'marks a corresponding notifications as read' do
        note = FactoryGirl.create(:notification, :recipient => @user, :target => @person, :unread => true)

        expect {
          get :show, :id => @person.to_param
          note.reload
        }.to change(Notification.where(:unread => true), :count).by(-1)
      end
    end

    context "when the person is not a contact of the current user" do
      before do
        @person = eve.person
      end

      it "succeeds" do
        get :show, :id => @person.to_param
        expect(response).to be_success
      end

      it 'succeeds on the mobile site' do
        get :show, :id => @person.to_param, :format => :mobile
        expect(response).to be_success
      end
    end
  end

  describe '#stream' do
    it "redirects non-json requests" do
      get :stream, person_id: @user.person.to_param
      expect(response).to be_redirect
    end

    context "person is current user" do
      it "assigns all the user's posts" do
        expect(@user.posts).to be_empty
        @user.post(:status_message, :text => "to one aspect", :to => @aspect.id)
        @user.post(:status_message, :text => "to all aspects", :to => 'all')
        @user.post(:status_message, :text => "public", :to => 'all', :public => true)
        expect(@user.reload.posts.length).to eq(3)
        get :stream, person_id: @user.person.to_param, format: :json
        expect(assigns(:stream).posts.map(&:id)).to match_array(@user.posts.map(&:id))
      end

      it "renders the comments on the user's posts" do
        cmmt = 'I mean it'
        message = @user.post :status_message, :text => 'test more', :to => @aspect.id
        @user.comment!(message, cmmt)
        get :stream, person_id: @user.person.to_param, format: :json
        expect(response).to be_success
        expect(response.body).to include(cmmt)
      end
    end

    context "person is contact of current user" do
      before do
        @person = bob.person
      end

      it "includes reshares" do
        reshare = @user.post(:reshare, :public => true, :root_guid => FactoryGirl.create(:status_message, :public => true).guid, :to => alice.aspect_ids)
        get :stream, person_id: @user.person.to_param, format: :json
        expect(assigns[:stream].posts.map { |x| x.id }).to include(reshare.id)
      end

      it "assigns only the posts the current user can see" do
        expect(bob.posts).to be_empty
        posts_user_can_see = []
        aspect_user_is_in = bob.aspects.where(:name => "generic").first
        aspect_user_is_not_in = bob.aspects.where(:name => "empty").first
        posts_user_can_see << bob.post(:status_message, :text => "to an aspect @user is in", :to => aspect_user_is_in.id)
        bob.post(:status_message, :text => "to an aspect @user is not in", :to => aspect_user_is_not_in.id)
        posts_user_can_see << bob.post(:status_message, :text => "to all aspects", :to => 'all')
        posts_user_can_see << bob.post(:status_message, :text => "public", :to => 'all', :public => true)
        expect(bob.reload.posts.length).to eq(4)

        get :stream, person_id: @person.to_param, format: :json
        expect(assigns(:stream).posts.map(&:id)).to match_array(posts_user_can_see.map(&:id))
      end
    end

    context "person is not contact of current user" do
      before do
        @person = eve.person
      end

      it "assigns only public posts" do
        expect(eve.posts).to be_empty
        eve.post(:status_message, :text => "to an aspect @user is not in", :to => eve.aspects.first.id)
        eve.post(:status_message, :text => "to all aspects", :to => 'all')
        public_post = eve.post(:status_message, :text => "public", :to => 'all', :public => true)
        expect(eve.reload.posts.length).to eq(3)

        get :stream, person_id: @person.to_param, format: :json
        expect(assigns[:stream].posts.map(&:id)).to match_array([public_post].map(&:id))
      end

      it "posts include reshares" do
        reshare = @user.post(:reshare, :public => true, :root_guid => FactoryGirl.create(:status_message, :public => true).guid, :to => alice.aspect_ids)
        get :stream, person_id: @user.person.to_param, format: :json
        expect(assigns[:stream].posts.map { |x| x.id }).to include(reshare.id)
      end
    end

    context "logged out" do
      before do
        sign_out :user
        @person = bob.person
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
          reshare = @user.post(:reshare, :public => true, :root_guid => FactoryGirl.create(:status_message, :public => true).guid, :to => alice.aspect_ids)
          get :stream, person_id: @user.person.to_param, format: :json
          expect(assigns[:stream].posts.map { |x| x.id }).to include(reshare.id)
        end

        it "assigns only public posts" do
          get :stream, person_id: @person.to_param, format: :json
          expect(assigns[:stream].posts.map(&:id)).to match_array(@public_posts.map(&:id))
        end

        it 'is sorted by created_at desc' do
          get :stream, person_id: @person.to_param, format: :json
          expect(assigns[:stream].stream_posts).to eq(@public_posts.sort_by { |p| p.created_at }.reverse)
        end
      end
    end
  end

  describe '#hovercard' do
    before do
      @hover_test = FactoryGirl.create(:person)
      @hover_test.profile.tag_string = '#test #tags'
      @hover_test.profile.save!
    end

    it 'redirects html requests' do
      get :hovercard, :person_id => @hover_test.guid
      expect(response).to redirect_to person_path(:id => @hover_test.guid)
    end

    it 'returns json with profile stuff' do
      get :hovercard, :person_id => @hover_test.guid, :format => 'json'
      expect(JSON.parse( response.body )['handle']).to eq(@hover_test.diaspora_handle)
    end
  end

  describe '#refresh_search ' do
    before(:each)do
      @eugene = FactoryGirl.create(:person,
                      :profile => FactoryGirl.build(:profile, :first_name => "Eugene", :last_name => "w"))
      @korth = FactoryGirl.create(:person,
                     :profile => FactoryGirl.build(:profile, :first_name => "Evan", :last_name => "Korth"))
    end

    describe 'via json' do
      it 'returns a zero count when a search fails' do
        get :refresh_search, :q => "weweweKorth", :format => 'json'
        expect(response.body).to eq({:search_count=>0, :search_html=>""}.to_json)
      end

      it 'returns with a zero count unless a fully composed name is sent' do
        get :refresh_search, :q => "Korth"
        expect(response.body).to eq({:search_count=>0, :search_html=>""}.to_json)
      end
      it 'returns with a found name' do
        get :refresh_search, :q => @korth.diaspora_handle
        expect(JSON.parse( response.body )["search_count"]).to eq(1)
      end
    end
  end


  describe '#contacts' do
    it 'assigns the contacts of a person' do
      contact = alice.contact_for(bob.person)
      contacts = contact.contacts
      get :contacts, :person_id => bob.person.to_param
      expect(assigns(:contacts_of_contact).to_a).to eq(contacts.to_a)
      expect(response).to be_success
    end

    it 'shows an error when invalid person id' do
      get :contacts, :person_id => 'foo'
      expect(flash[:error]).to be_present
      expect(response).to redirect_to people_path
    end
  end

  describe '#diaspora_id?' do
    it 'returns true for pods on urls' do
      expect(@controller.send(:diaspora_id?, "ilya_123@pod.geraspora.de")).to be true
    end

    it 'returns true for pods on urls with port' do
      expect(@controller.send(:diaspora_id?, "ilya_123@pod.geraspora.de:12314")).to be true
    end

    it 'returns true for pods on localhost' do
      expect(@controller.send(:diaspora_id?, "ilya_123@localhost")).to be true
    end

    it 'returns true for pods on localhost and port' do
      expect(@controller.send(:diaspora_id?, "ilya_123@localhost:1234")).to be true
    end

    it 'returns true for pods on ip' do
      expect(@controller.send(:diaspora_id?, "ilya_123@1.1.1.1")).to be true
    end

    it 'returns true for pods on ip and port' do
      expect(@controller.send(:diaspora_id?, "ilya_123@1.2.3.4:1234")).to be true
    end

    it 'returns false for pods on with invalid url characters' do
      expect(@controller.send(:diaspora_id?, "ilya_123@join_diaspora.com")).to be false
    end

    it 'returns false for invalid usernames' do
      expect(@controller.send(:diaspora_id?, "ilya_2%3@joindiaspora.com")).to be false
    end
  end
end
