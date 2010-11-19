#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PeopleController do
  render_views

  let(:user) { Factory(:user) }
  let!(:aspect) { user.aspects.create(:name => "lame-os") }

  before do
    sign_in :user, user
  end

  describe '#index' do
    before do
      @eugene = Factory.create(:person, :profile => {:first_name => "Eugene", :last_name => "w"})
      @korth  = Factory.create(:person, :profile => {:first_name => "Evan", :last_name => "Korth"})
    end

    it "yields search results for substring of person name" do
      get :index, :q => "Eu"
      assigns[:people].should include @eugene
    end

    it 'shows a contact' do
      user2 = make_user
      connect_users(user, aspect, user2, user2.aspects.create(:name => 'Neuroscience'))
      get :index
      assigns[:people].should include user2.person
      response.should be_success
    end

    it 'shows a non-contact' do
      user2 = make_user
      user2.person.profile.searchable = true
      user2.save
      get :index
      assigns[:people].should include user2.person
      response.should be_success
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
    it 'should go to the current_user show page' do
      get :show, :id => user.person.id
      response.should be_success
    end

    it "redirects on an invalid id" do
      get :show, :id => 'delicious'
      response.should redirect_to people_path
    end

    it "redirects on a nonexistent person" do
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
  end

  describe '#update' do
    context 'with a profile photo set' do
      before do
        @params = { :profile =>
                   { :image_url => "",
                     :last_name  => user.person.profile.last_name,
                     :first_name => user.person.profile.first_name }}

        user.person.profile.image_url = "http://tom.joindiaspora.com/images/user/tom.jpg"
        user.person.profile.save
      end
      it "doesn't overwrite the profile photo when an empty string is passed in" do
        image_url = user.person.profile.image_url
        put :update, :id => user.person.id.to_s, :person => @params

        user.person.reload
        user.person.profile.image_url.should == image_url
      end
      it 'updates a profile photo url' do
        fixture_name = File.dirname(__FILE__) + '/../fixtures/button.png'
        photo = user.post(:photo, :user_file => File.open(fixture_name), :to => aspect.id)
        @params[:profile][:image_url] = photo.url(:thumb_medium)
        put :update, :id => user.person.id, :person => @params
        goal_pod_url = (APP_CONFIG[:pod_url][-1,1] == '/' ? APP_CONFIG[:pod_url].chop : APP_CONFIG[:pod_url])
        user.person.reload.profile.image_url.should ==
          "#{goal_pod_url}#{photo.url(:thumb_medium)}"
      end
    end
    it 'does not allow mass assignment' do
      new_user = make_user
      put :update, :id => user.person.id, :person => {
        :owner_id => new_user.id}
      user.person.reload.owner_id.should_not == new_user.id
    end

    it 'does not overwrite the profile diaspora handle' do
      handle_params = {'profile' => {'diaspora_handle' => 'abc@a.com'}}
      put :update, :id => user.person.id, :person => handle_params
      user.person.reload.profile[:diaspora_handle].should_not == 'abc@a.com'
    end
  end
end
