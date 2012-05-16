#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ProfilesController do
  before do
    sign_in :user, eve
  end

  describe '#show' do
    let(:mock_person) {mock_model(User)}
    let(:mock_presenter) { mock(:as_json => {:rock_star => "Jamie Cai"})}

    it "returns a post Presenter" do
      Person.should_receive(:find_by_guid!).with("12345").and_return(mock_person)
      PersonPresenter.should_receive(:new).with(mock_person, eve).and_return(mock_presenter)

      get :show, :id => 12345, :format => :json
      response.body.should == {:rock_star => "Jamie Cai"}.to_json
    end
  end

  describe '#edit' do 
    it 'succeeds' do
      get :edit
      response.should be_success
    end

    it 'sets the profile to the current users profile' do
      get :edit
      assigns[:profile].should == eve.person.profile
    end

    it 'sets the aspect to "person_edit" ' do
      get :edit
      assigns[:aspect].should == :person_edit
    end

    it 'sets the person to the current users person' do
      get :edit
      assigns[:person].should == eve.person
    end
  end

  describe '#update' do
    it "sets the flash" do
      put :update, :profile => {
          :image_url  => "",
          :first_name => "Will",
          :last_name  => "Smith"
        }
      flash[:notice].should_not be_blank
    end

    it "sets nsfw" do
      eve.person(true).profile.nsfw.should == false
      put :update, :profile => { :id => eve.person.id, :nsfw => "1" }
      eve.person(true).profile.nsfw.should == true
    end

    it "unsets nsfw" do
      eve.person.profile.nsfw = true
      eve.person.profile.save

      eve.person(true).profile.nsfw.should == true
      put :update, :profile => { :id => eve.person.id }
      eve.person(true).profile.nsfw.should == false
    end

    it 'sets tags' do
      params = { :id => eve.person.id,
                 :tags => '#apples #oranges'}

      put :update, params
      eve.person(true).profile.tag_list.to_set.should == ['apples', 'oranges'].to_set
    end
    
    it 'sets plaintext tags' do
      params = { :id => eve.person.id,
                 :tags => ',#apples,#oranges,',
                 :profile => {:tag_string => '#pears'} }
      
      put :update, params
      eve.person(true).profile.tag_list.to_set.should == ['apples', 'oranges', 'pears'].to_set
    end

    it 'sets plaintext tags without #' do
      params = { :id => eve.person.id,
                 :tags => ',#apples,#oranges,',
                 :profile => {:tag_string => 'bananas'} }
      
      put :update, params
      eve.person(true).profile.tag_list.to_set.should == ['apples', 'oranges', 'bananas'].to_set
    end

    it 'sets valid birthday' do
      params = { :id => eve.person.id,
                 :profile => {
                   :date => {
                     :year => '2001',
                     :month => '02',
                     :day => '28' } } }

      put :update, params
      eve.person(true).profile.birthday.year.should == 2001
      eve.person(true).profile.birthday.month.should == 2
      eve.person(true).profile.birthday.day.should == 28
    end

    it 'displays error for invalid birthday' do
      params = { :id => eve.person.id,
                 :profile => {
                   :date => {
                     :year => '2001',
                     :month => '02',
                     :day => '31' } } }

      put :update, params
      flash[:error].should_not be_blank
    end

    context 'with a profile photo set' do
      before do
        @params = { :id => eve.person.id,
                    :profile =>
                     {:image_url => "",
                      :last_name  => eve.person.profile.last_name,
                      :first_name => eve.person.profile.first_name }}

        eve.person.profile.image_url = "http://tom.joindiaspora.com/images/user/tom.jpg"
        eve.person.profile.save
      end

      it "doesn't overwrite the profile photo when an empty string is passed in" do
        image_url = eve.person.profile.image_url
        put :update, @params

        Person.find(eve.person.id).profile.image_url.should == image_url
      end
    end

    context 'mass assignment' do
      before do
        new_person = FactoryGirl.create(:person)
        @profile_params = {:profile =>{ :person_id => new_person.id,
                                    :diaspora_handle => 'abc@a.com'}}
      end

      it 'person_id' do
        person = eve.person
        profile = person.profile
        put :update, @profile_params
        profile.reload.person_id.should == person.id
      end

      it 'diaspora handle' do
        put :update, @profile_params
        Person.find(eve.person.id).profile[:diaspora_handle].should_not == 'abc@a.com'
      end
    end
  end

  describe '#upload_wallpaper_image' do
    it 'returns a success=false response if the photo param is not present' do
      post :upload_wallpaper_image, :format => :json
      JSON.parse(response.body).should include("success" => false)
    end

    it 'stores the wallpaper for the current_user' do
      # we should have another test here asserting that the wallpaper is set... i was having problems testing
      # this behavior though :(
      
      @controller.stub!(:current_user).and_return(eve)
      @controller.stub!(:remotipart_submitted?).and_return(true)
      @controller.stub!(:file_handler).and_return(uploaded_photo)
      @params = {:photo => {:user_file => uploaded_photo} }

      eve.person.profile.wallpaper.should_receive(:store!)
      post :upload_wallpaper_image, @params.merge(:format => :json)
    end
  end
end