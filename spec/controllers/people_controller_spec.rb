#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PeopleController do
  render_views

  let(:user)    { make_user }
  let!(:aspect) { user.aspects.create(:name => "lame-os") }

  before do
    sign_in :user, user
  end

  describe '#similar_people' do
    before do
      @contacts = []
      @aspect1 = user.aspects.create(:name => "foos")
      @aspect2 = user.aspects.create(:name => "bars")

      3.times do
        @contacts << Contact.create(:user => user, :person => Factory.create(:person))
      end
    end

    it 'returns people in mutual aspects' do
      @contacts[0].aspects << @aspect1
      @contacts[1].aspects << @aspect1
      @contacts[0].save
      @contacts[1].save

      @controller.similar_people(@contacts[0]).should include(@contacts[1].person)
    end

    it 'does not return people in non-mutual aspects' do
      @contacts[0].aspects << @aspect1
      @contacts[1].aspects << @aspect1
      @contacts[0].save
      @contacts[1].save

      @controller.similar_people(@contacts[0]).should_not include(@contacts[2].person)
    end

    it 'does not return the original contacts person' do
      @contacts[0].aspects << @aspect1
      @contacts[1].aspects << @aspect1
      @contacts[0].save
      @contacts[1].save

      @controller.similar_people(@contacts[0]).should_not include(@contacts[0].person)
    end

    it 'returns at max 5 similar people' do
      @contacts[0].aspects << @aspect1
      @contacts[0].save

      20.times do
        c = Contact.create(:user => user, :person => Factory.create(:person))
        c.aspects << @aspect1
        c.save
        @contacts << c
      end

      @controller.similar_people(@contacts[0]).count.should == 5
    end
  end

  describe '#share_with' do
    before do
      @person = Factory.create(:person)
    end
    it 'succeeds' do
      get :share_with, :id => @person.id
      response.should be_success
    end
  end
  describe '#hashes_from_people' do
    before do
      @everyone = []
      10.times do
        @everyone << Factory.create(:person)
      end

      user.send_contact_request_to(@everyone[3], aspect)
      user.send_contact_request_to(@everyone[2], aspect)
      user.activate_contact(@everyone[4], aspect)
      user.activate_contact(@everyone[5], aspect)

      user.reload
      user.aspects.reload
      @people = @everyone
      @people.length.should == 10
      @hashes = @controller.hashes_for_people(@people, user.aspects)
    end
    it 'has the correct result for no relationship' do
      hash = @hashes.first

      hash[:person].should == @people.first
      hash[:contact].should be_false
      hash[:request].should be_false
      hash[:aspects].should == user.aspects
    end
    it 'has the correct result for a connected person' do
      hash = @hashes[4]
      hash[:person].should == @people[4]
      hash[:contact].should be_true
      hash[:contact].should_not be_pending
      hash[:aspects].should == user.aspects
    end
    it 'has the correct result for a requested person' do
      hash = @hashes[2]
      hash[:person].should == @people[2]
      hash[:contact].should be_true
      hash[:contact].should be_pending
      hash[:aspects].should == user.aspects
    end
  end
  describe '#index' do
    before do
      @eugene = Factory.create(:person,
        :profile => {:first_name => "Eugene",
                     :last_name => "w"})
      @korth  = Factory.create(:person,
        :profile => {:first_name => "Evan",
                     :last_name => "Korth"})
    end

    it "assigns hashes" do
      eugene2 = Factory.create(:person,
        :profile => {:first_name => "Eugene",
                     :last_name => "w"})
      get :index, :q => "Eu"
      people = assigns[:hashes].map{|h| h[:person]}
      people.should include @eugene
      people.should include eugene2
    end
    it "assigns people" do
      eugene2 = Factory.create(:person,
        :profile => {:first_name => "Eugene",
                     :last_name => "w"})
      get :index, :q => "Eu"
      assigns[:people].should =~ [@eugene, eugene2]
    end
    it 'shows a contact' do
      user2 = make_user
      connect_users(user, aspect, user2, user2.aspects.create(:name => 'Neuroscience'))
      get :index, :q => user2.person.profile.first_name.to_s
      response.should redirect_to user2.person
    end

    it 'shows a non-contact' do
      user2 = make_user
      user2.person.profile.searchable = true
      user2.save
      get :index, :q => user2.person.profile.first_name.to_s
      response.should redirect_to user2.person
    end

    it "redirects to person page if there is exactly one match" do
      get :index, :q => "Korth"
      response.should redirect_to @korth
    end

    it "does not redirect if there are no matches" do
      get :index, :q => "Korthsauce"
      response.should_not be_redirect
    end
  end

  describe '#show' do
    it 'goes to the current_user show page' do
      get :show, :id => user.person.id
      response.should be_success
    end

    it 'renders with a post' do
      user.post :status_message, :message => 'test more', :to => aspect.id
      get :show, :id => user.person.id
      response.should be_success
    end

    it 'renders with a post' do
      message = user.post :status_message, :message => 'test more', :to => aspect.id
      user.comment 'I mean it', :on => message
      get :show, :id => user.person.id
      response.should be_success
    end

    it "redirects to #index if the id is invalid" do
      get :show, :id => 'delicious'
      response.should redirect_to people_path
    end

    it "redirects to #index if no person is found" do
      get :show, :id => user.id
      response.should redirect_to people_path
    end

    it "renders the show page of a contact" do
      user2 = make_user
      connect_users(user, aspect, user2, user2.aspects.create(:name => 'Neuroscience'))
      get :show, :id => user2.person.id
      response.should be_success
    end

    it "renders the show page of a non-contact" do
      user2 = make_user
      get :show, :id => user2.person.id
      response.should be_success
    end

    it "renders with public posts of a non-contact" do
      user2 = make_user
      status_message = user2.post(:status_message, :message => "hey there", :to => 'all', :public => true)

      get :show, :id => user2.person.id
      response.body.should include status_message.message
    end
  end

  describe '#webfinger' do
    it 'enqueues a webfinger job' do
      Resque.should_receive(:enqueue).with(Jobs::SocketWebfinger, user.id, user.diaspora_handle, anything).once
      get :retrieve_remote, :diaspora_handle => user.diaspora_handle
    end
  end

  describe '#update' do
    it "sets the flash" do
      put :update, :id => user.person.id,
        :profile => {
          :image_url  => "",
          :first_name => "Will",
          :last_name  => "Smith"
        }
      flash[:notice].should_not be_empty
    end

    context 'with a profile photo set' do
      before do
        @params = { :id => user.person.id,
                    :profile =>
                     {:image_url => "",
                      :last_name  => user.person.profile.last_name,
                      :first_name => user.person.profile.first_name }}

        user.person.profile.image_url = "http://tom.joindiaspora.com/images/user/tom.jpg"
        user.person.profile.save
      end
      it "doesn't overwrite the profile photo when an empty string is passed in" do
        image_url = user.person.profile.image_url
        put :update, @params

        user.person.reload
        user.person.profile.image_url.should == image_url
      end
    end
    it 'does not allow mass assignment' do
      new_user = make_user
      put :update, :id => user.person.id, :owner_id => new_user.id
      user.person.reload.owner_id.should_not == new_user.id
    end

    it 'does not overwrite the profile diaspora handle' do
      handle_params = {:id => user.person.id,
                       :profile => {:diaspora_handle => 'abc@a.com'} }
      put :update, handle_params
      user.person.reload.profile[:diaspora_handle].should_not == 'abc@a.com'
    end
  end
end
