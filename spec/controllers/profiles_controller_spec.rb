#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


require 'spec_helper'

describe ProfilesController do
  render_views
  before do
    @user = eve
    sign_in :user, @user
  end

  describe '#edit' do 
    it 'succeeds' do
      get :edit
      response.should be_success
    end

    it 'sets the profile to the current users profile' do
      get :edit
      assigns[:profile].should == @user.person.profile
    end

    it 'sets the aspect to "person_edit" ' do
      get :edit
      assigns[:aspect].should == :person_edit
    end

    it 'sets the person to the current users person' do
      get :edit
      assigns[:person].should == @user.person
    end
  end

  describe '#update' do
    it "sets the flash" do
      put :update, :profile => {
          :image_url  => "",
          :first_name => "Will",
          :last_name  => "Smith"
        }
      flash[:notice].should_not be_empty
    end

    it 'sets tags' do
      params = { :id => @user.person.id,
                  :profile =>
                   { :tag_string => '#apples #oranges'}}

      put :update, params
      @user.person(true).profile.tag_list.to_set.should == ['apples', 'oranges'].to_set
    end

    context 'with a profile photo set' do
      before do
        @params = { :id => @user.person.id,
                    :profile =>
                     {:image_url => "",
                      :last_name  => @user.person.profile.last_name,
                      :first_name => @user.person.profile.first_name }}

        @user.person.profile.image_url = "http://tom.joindiaspora.com/images/user/tom.jpg"
        @user.person.profile.save
      end
      it "doesn't overwrite the profile photo when an empty string is passed in" do
        image_url = @user.person.profile.image_url
        put :update, @params

        Person.find(@user.person.id).profile.image_url.should == image_url
      end
    end

    context 'mass assignment' do
      before do
        new_person = Factory(:person)
        @profile_params = {:profile =>{ :person_id => new_person.id,
                                    :diaspora_handle => 'abc@a.com'}}
      end
      it 'person_id' do
        person = @user.person
        profile = person.profile
        put :update, @profile_params
        profile.reload.person_id.should == person.id
      end

      it 'diaspora handle' do
        put :update, @profile_params
        Person.find(@user.person.id).profile[:diaspora_handle].should_not == 'abc@a.com'
      end
    end
  end
end
