#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AspectsController do
  before do
    alice.getting_started = false
    alice.save
    sign_in :user, alice
    @alices_aspect_1 = alice.aspects.where(:name => "generic").first
    @alices_aspect_2 = alice.aspects.create(:name => "another aspect")

    @controller.stub(:current_user).and_return(alice)
    request.env["HTTP_REFERER"] = 'http://' + request.host
  end


  describe "#new" do
    it "renders a remote form if remote is true" do
      get :new, "remote" => "true"
      response.should be_success
      response.body.should =~ /#{Regexp.escape('data-remote="true"')}/
    end
    it "renders a non-remote form if remote is false" do
      get :new, "remote" => "false"
      response.should be_success
      response.body.should_not =~ /#{Regexp.escape('data-remote="true"')}/
    end
    it "renders a non-remote form if remote is missing" do
      get :new
      response.should be_success
      response.body.should_not =~ /#{Regexp.escape('data-remote="true"')}/
    end
  end

  describe "#index" do
    it 'renders just the stream with the infinite scroll param set' do
      get :index, :only_posts => true
      response.should render_template('shared/_stream')
    end

    it 'assigns an Stream::Aspect' do
      get :index
      assigns(:stream).class.should == Stream::Aspect
    end

    describe 'filtering by aspect' do
      before do
        @aspect1 = alice.aspects.create(:name => "test aspect")
        @stream = Stream::Aspect.new(alice, [])
        @stream.stub(:posts).and_return([])
      end

      it 'respects a single aspect' do
        Stream::Aspect.should_receive(:new).with(alice, [@aspect1.id], anything).and_return(@stream)
        get :index, :a_ids => [@aspect1.id]
      end

      it 'respects multiple aspects' do
        aspect2 = alice.aspects.create(:name => "test aspect two")
        Stream::Aspect.should_receive(:new).with(alice, [@aspect1.id, aspect2.id], anything).and_return(@stream)
        get :index, :a_ids => [@aspect1.id, aspect2.id]
      end
    end

    describe 'performance', :performance => true do
      before do
        require 'benchmark'
        8.times do |n|
          user = Factory.create(:user)
          aspect = user.aspects.create(:name => 'people')
          connect_users(alice, @alices_aspect_1, user, aspect)
          post = alice.post(:status_message, :text => "hello#{n}", :to => @alices_aspect_2.id)
          8.times do |n|
            user.comment "yo#{post.text}", :post => post
          end
        end
      end
      it 'takes time' do
        Benchmark.realtime {
          get :index
        }.should < 1.5
      end
    end
  end

  describe "#show" do
    it "succeeds" do
      get :show, 'id' => @alices_aspect_1.id.to_s
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
        alice.aspects.count.should == 2
        post :create, "aspect" => {"name" => "new aspect"}
        alice.reload.aspects.count.should == 3
      end
      it "redirects to the aspect's contact page" do
        post :create, "aspect" => {"name" => "new aspect"}
        response.should redirect_to(contacts_path(:a_id => Aspect.find_by_name("new aspect").id))
      end

      context "with person_id param" do
        it "creates a contact if one does not already exist" do
          lambda {
            post :create, :format => 'js', :aspect => {:name => "new", :person_id => eve.person.id}
          }.should change {
            alice.contacts.count
          }.by(1)
        end

        it "adds a new contact to the new aspect" do
          post :create, :format => 'js', :aspect => {:name => "new", :person_id => eve.person.id}
          alice.aspects.find_by_name("new").contacts.count.should == 1
        end

        it "adds an existing contact to the new aspect" do
          post :create, :format => 'js', :aspect => {:name => "new", :person_id => bob.person.id}
          alice.aspects.find_by_name("new").contacts.count.should == 1
        end
      end
    end
    context "with invalid params" do
      it "does not create an aspect" do
        alice.aspects.count.should == 2
        post :create, "aspect" => {"name" => ""}
        alice.reload.aspects.count.should == 2
      end
      it "goes back to the page you came from" do
        post :create, "aspect" => {"name" => ""}
        response.should redirect_to(:back)
      end
    end
  end

  describe "#update" do
    before do
      @alices_aspect_1 = alice.aspects.create(:name => "Bruisers")
    end

    it "doesn't overwrite random attributes" do
      new_user = Factory.create :user
      params = {"name" => "Bruisers"}
      params[:user_id] = new_user.id
      put('update', :id => @alices_aspect_1.id, "aspect" => params)
      Aspect.find(@alices_aspect_1.id).user_id.should == alice.id
    end
  end

  describe '#edit' do
    before do
      eve.profile.first_name = eve.profile.last_name = nil
      eve.profile.save
      eve.save

      @zed = Factory(:user_with_aspect, :username => "zed")
      @zed.profile.first_name = "zed"
      @zed.profile.save
      @zed.save
      @katz = Factory(:user_with_aspect, :username => "katz")
      @katz.profile.first_name = "katz"
      @katz.profile.save
      @katz.save

      connect_users(alice, @alices_aspect_2, eve, eve.aspects.first)
      connect_users(alice, @alices_aspect_2, @zed, @zed.aspects.first)
      connect_users(alice, @alices_aspect_1, @katz, @katz.aspects.first)
    end

    it 'renders' do
      get :edit, :id => @alices_aspect_1.id
      response.should be_success
    end

    it 'assigns the contacts in alphabetical order with people in aspects first' do
      get :edit, :id => @alices_aspect_2.id
      assigns[:contacts].map(&:id).should == [alice.contact_for(eve.person), alice.contact_for(@zed.person), alice.contact_for(bob.person), alice.contact_for(@katz.person)].map(&:id)
    end

    it 'assigns all the contacts if noone is there' do
      alices_aspect_3 = alice.aspects.create(:name => "aspect 3")

      get :edit, :id => alices_aspect_3.id
      assigns[:contacts].map(&:id).should == [alice.contact_for(bob.person), alice.contact_for(eve.person), alice.contact_for(@katz.person), alice.contact_for(@zed.person)].map(&:id)
    end

    it 'eager loads the aspect memberships for all the contacts' do
      get :edit, :id => @alices_aspect_2.id
      assigns[:contacts].each do |c|
        c.aspect_memberships.loaded?.should be_true
      end
    end
  end

  describe "#toggle_contact_visibility" do
    it 'sets contacts visible' do
      @alices_aspect_1.contacts_visible = false
      @alices_aspect_1.save

      get :toggle_contact_visibility, :format => 'js', :aspect_id => @alices_aspect_1.id
      @alices_aspect_1.reload.contacts_visible.should be_true
    end

    it 'sets contacts hidden' do
      @alices_aspect_1.contacts_visible = true
      @alices_aspect_1.save

      get :toggle_contact_visibility, :format => 'js', :aspect_id => @alices_aspect_1.id
      @alices_aspect_1.reload.contacts_visible.should be_false
    end
  end

  context 'helper methods' do
    before do
      @tag = ActsAsTaggableOn::Tag.create!(:name => "partytimeexcellent")
      TagFollowing.create!(:tag => @tag, :user => alice)
      alice.should_receive(:followed_tags).once.and_return([42])
    end

    describe 'tags' do
      it 'queries current_users tag if there are tag_followings' do
        @controller.tags.should == [42]
      end

      it 'does not query twice' do
        @controller.tags.should == [42]
        @controller.tags.should == [42]
      end
    end
  end

  describe "mobile site" do
    before do
      ap = alice.person
      posts = []
      posts << alice.post(:reshare, :root_guid => Factory(:status_message, :public => true).guid, :to => 'all')
      posts << alice.post(:status_message, :text => 'foo', :to => alice.aspects)
      photo = Factory(:activity_streams_photo, :public => true, :author => ap)
      posts << photo
      posts.each do |p|
        alice.build_like(:positive => true, :target => p).save
      end
      alice.add_to_streams(photo, alice.aspects)
      sign_in alice
    end

    it 'should not 500' do
      get :index, :format => :mobile
      response.should be_success
    end
  end
end
