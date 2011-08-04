#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, "spec", "shared_behaviors", "log_override")

describe AspectsController do
  before do
    alice.getting_started = false
    alice.save
    sign_in :user, alice
    @alices_aspect_1  = alice.aspects.first
    @alices_aspect_2  = alice.aspects.create(:name => "another aspect")

    @controller.stub(:current_user).and_return(alice)
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
      @action_params = {'id' => @alices_aspect_1.id.to_s}
    end
    it_should_behave_like "it overrides the logs on redirect"
  end

  describe "#index" do
    it "generates a jasmine fixture", :fixture => true do
      get :index
      save_fixture(html_for("body"), "aspects_index")
    end

    it "generates a jasmine fixture with a prefill", :fixture => true do
      get :index, :prefill => "reshare things"
      save_fixture(html_for("body"), "aspects_index_prefill")
    end

    it 'generates a jasmine fixture with services', :fixture => true do
      alice.services << Services::Facebook.create(:user_id => alice.id)
      alice.services << Services::Twitter.create(:user_id => alice.id)
      get :index, :prefill => "reshare things"
      save_fixture(html_for("body"), "aspects_index_services")
    end

    it 'generates a jasmine fixture with posts', :fixture => true do
      message = alice.post(:status_message, :text => "hello "*800, :to => @alices_aspect_2.id)
      3.times { bob.comment("what", :post => message) }
      get :index
      save_fixture(html_for("body"), "aspects_index_with_posts")

      save_fixture(html_for(".stream_element:first"), "status_message_in_stream")
    end

    context 'with getting_started = true' do
      before do
        alice.getting_started = true
        alice.save
      end
      
      it 'does not redirect mobile users to getting_started' do
        get :index, :format => :mobile
        response.should_not be_redirect
      end

      it 'does not redirect ajax to getting_started' do
        get :index, :format => :js
        response.should_not be_redirect
      end
    end

    context 'with no aspects' do
      before do
        alice.aspects.each { |aspect| aspect.destroy }
        alice.reload
      end

      it 'redirects to the new aspect page' do
        get :index
        response.should redirect_to new_aspect_path
      end
    end

    context 'with posts in multiple aspects' do
      before do
        @posts = []
        2.times do |n|
          user = Factory(:user)
          aspect = user.aspects.create(:name => 'people')
          connect_users(alice, @alices_aspect_1, user, aspect)
          target_aspect = n.even? ? @alices_aspect_1 : @alices_aspect_2
          post = alice.post(:status_message, :text=> "hello#{n}", :to => target_aspect)
          post.created_at = Time.now - (2 - n).seconds
          post.save!
          @posts << post
        end
        alice.build_comment(:text => 'lalala', :post => @posts.first ).save
      end

      describe "post visibilities" do
        before do
          @status = bob.post(:status_message, :text=> "hello", :to => bob.aspects.first)
          @vis = @status.post_visibilities.first
        end

        it "pulls back non hidden posts" do
          get :index
          assigns[:posts].include?(@status).should be_true
        end
        it "does not pull back hidden posts" do
          @vis.update_attributes( :hidden => true )
          get :index
          assigns[:posts].include?(@status).should be_false
        end
      end

      describe 'infinite scroll' do
        it 'renders with the infinite scroll param' do
          get :index, :only_posts => true
          assigns[:posts].include?(@posts.first).should be_true
          response.should be_success
        end

      end

      describe "ordering" do
        it "orders posts by updated_at by default" do
          get :index
          assigns(:posts).should == @posts
        end

        it "orders posts by created_at on request" do
          get :index, :sort_order => 'created_at'
          assigns(:posts).should == @posts.reverse
        end

        it "remembers your sort order and lets you override the memory" do
          get :index, :sort_order => "created_at"
          assigns(:posts).should == @posts.reverse
          get :index
          assigns(:posts).should == @posts.reverse
          get :index, :sort_order => "updated_at"
          assigns(:posts).should == @posts
        end

        it "doesn't allow SQL injection" do
          get :index, :sort_order => "\"; DROP TABLE users;"
          assigns(:posts).should == @posts
          get :index, :sort_order => "created_at"
          assigns(:posts).should == @posts.reverse
        end
      end

      it "returns all posts by default" do
        alice.aspects.reload
        get :index
        assigns(:posts).length.should == 2
      end

      it "posts include reshares" do
        reshare = alice.post(:reshare, :public => true, :root_guid => Factory(:status_message, :public => true).guid, :to => alice.aspects)
        get :index
        assigns[:posts].map{|x| x.id}.should include(reshare.id)
      end

      it "can filter to a single aspect" do
        get :index, :a_ids => [@alices_aspect_2.id.to_s]
        assigns(:posts).length.should == 1
      end

      it "can filter to multiple aspects" do
        get :index, :a_ids => [@alices_aspect_1.id.to_s, @alices_aspect_2.id.to_s]
        assigns(:posts).length.should == 2
      end
    end

    describe 'performance', :performance => true do
      before do
        require 'benchmark'
        8.times do |n|
          user = Factory.create(:user)
          aspect = user.aspects.create(:name => 'people')
          connect_users(alice, @alices_aspect_1, user, aspect)
          post =  alice.post(:status_message, :text => "hello#{n}", :to => @alices_aspect_2.id)
          8.times do |n|
            user.comment "yo#{post.text}", :post => post
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
          }.should change{
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
      new_user         = Factory.create :user
      params           = {"name" => "Bruisers"}
      params[:user_id] = new_user.id
      put('update', :id => @alices_aspect_1.id, "aspect" => params)
      Aspect.find(@alices_aspect_1.id).user_id.should == alice.id
    end
  end

  describe '#edit' do
    before do
      eve.profile.first_name = nil
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
      alices_aspect_3  = alice.aspects.create(:name => "aspect 3")

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
      TagFollowing.create!(:tag => @tag, :user => alice )
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
