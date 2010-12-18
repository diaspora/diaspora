#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AspectsController do
  render_views

  before do
    @user  = make_user
    @user2 = make_user

    @aspect   = @user.aspects.create(:name => "lame-os")
    @aspect1  = @user.aspects.create(:name => "another aspect")
    @aspect2  = @user2.aspects.create(:name => "party people")

    connect_users(@user, @aspect, @user2, @aspect2)

    @contact = @user.contact_for(@user2.person)
    @user.getting_started = false
    @user.save
    sign_in :user, @user
    @controller.stub(:current_user).and_return(@user)
    request.env["HTTP_REFERER"] = 'http://' + request.host
  end

  describe "#index" do
    it "assigns @contacts to all the user's contacts" do
      Factory.create :person
      begin
      get :index
      rescue Exception => e
        raise e.original_exception
      end
      assigns[:contacts].should == @user.contacts
    end
    context 'performance' do
      before do
        require 'benchmark'
        @posts = []
        @users = []
        8.times do |n|
          user = make_user
          @users << user
          aspect = user.aspects.create(:name => 'people')
          connect_users(@user, @aspect, user, aspect)
          post =  @user.post(:status_message, :message => "hello#{n}", :to => @aspect1.id)
          @posts << post
          user.comment "yo#{post.message}", :on => post
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
      get :show, 'id' => @aspect.id.to_s
      response.should be_success
    end
    it "assigns aspect, aspect_contacts, and posts" do
      get :show, 'id' => @aspect.id.to_s
      assigns(:aspect).should == @aspect
      achash = @controller.send(:hashes_for_contacts, @aspect.contacts).first
      assigns(:aspect_contacts).first[:contact].should == achash[:contact]
      assigns(:aspect_contacts).first[:person].should == achash[:person]
      assigns(:posts).should == []
    end
    it "paginates" do
      16.times { |i| @user2.post(:status_message, :to => @aspect2.id, :message => "hi #{i}") }

      get :show, 'id' => @aspect.id.to_s
      assigns(:posts).count.should == 15

      get :show, 'id' => @aspect.id.to_s, 'page' => '2'
      assigns(:posts).count.should == 1
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
    before do
      @person = Factory.create(:person)
      @opts = {
        :person_id => @person.id,
        :from => @aspect.id,
        :to =>
          {:to => @aspect1.id}
      }
    end
    it 'calls the move_contact_method' do
      @controller.stub!(:current_user).and_return(@user)
      @user.should_receive(:move_contact)
      post :move_contact, @opts
    end
  end

  describe "#hashes_for_contacts" do
    before do
      @people = []
      10.times {@people << Factory.create(:person)}
      @people.each{|p| @user.reload.activate_contact(p, @user.aspects.first.reload)}
      @hashes = @controller.send(:hashes_for_contacts,@user.reload.contacts)
      @hash = @hashes.first
    end
    it 'has as many hashes as contacts' do
      @hashes.length.should == @user.contacts.length
    end
    it 'has a contact' do
      @hash[:contact].should == @user.contacts.first
    end
    it 'has a person' do
      @hash[:person].should == @user.contacts.first.person
    end
    it "does not select the person's rsa key" do
      @hash[:person].serialized_public_key.should be_nil
    end
  end
  describe "#hashes_for_aspects" do
    before do
      @people = []
      10.times {@people << Factory.create(:person)}
      @people.each{|p| @user.reload.activate_contact(p, @user.aspects.first.reload)}
      @user.reload
      @hashes = @controller.send(:hashes_for_aspects, @user.aspects, @user.contacts, :limit => 9)
      @hash = @hashes.first
      @aspect = @user.aspects.first
    end
    it 'has aspects' do
      @hashes.length.should == 2
      @hash[:aspect].should == @aspect
    end
    it 'has a contact_count' do
      @hash[:contact_count].should == @aspect.contacts.count
    end
    it 'takes a limit on contacts returned' do
      @hash[:contacts].count.should == 9
    end
    it 'has a person in each hash' do
      @aspect.contacts.map{|c| c.person}.include?(@hash[:contacts].first[:person]).should be_true
    end
    it "does not return the rsa key" do
      @hash[:contacts].first[:person].serialized_public_key.should be_nil
    end
    it 'has a contact in each hash' do
      @aspect.contacts.include?(@hash[:contacts].first[:contact]).should be_true
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
    context 'with an incoming request' do
      before do
        @user3 = make_user
        @user3.send_contact_request_to(@user.person, @user3.aspects.create(:name => "Walruses"))
      end
      it 'deletes the request' do
        post 'add_to_aspect',
          :format => 'js',
          :person_id => @user3.person.id,
          :aspect_id => @aspect1.id
        Request.from(@user3).to(@user).first.should be_nil
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

  describe "#remove_from_aspect" do
    it 'removes contacts from an aspect' do
      @user.add_contact_to_aspect(@contact, @aspect1)
      post 'remove_from_aspect',
        :format => 'js',
        :person_id => @user2.person.id,
        :aspect_id => @aspect.id
      response.should be_success
      @aspect.reload
      @aspect.contacts.include?(@contact).should be false
    end
  end
end
