#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ProfilesController do
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
      flash[:notice].should_not be_blank
    end

    it "sets nsfw" do
      @user.person(true).profile.nsfw.should == false
      put :update, :profile => { :id => @user.person.id, :nsfw => "1" }
      @user.person(true).profile.nsfw.should == true
    end

    it "unsets nsfw" do
      @user.person.profile.nsfw = true
      @user.person.profile.save

      @user.person(true).profile.nsfw.should == true
      put :update, :profile => { :id => @user.person.id }
      @user.person(true).profile.nsfw.should == false
    end

    it 'sets tags' do
      params = { :id => @user.person.id,
                 :tags => '#apples #oranges'}

      put :update, params
      @user.person(true).profile.tag_list.to_set.should == ['apples', 'oranges'].to_set
    end
    
    it 'sets plaintext tags' do
      params = { :id => @user.person.id,
                 :tags => ',#apples,#oranges,',
                 :profile => {:tag_string => '#pears'} }
      
      put :update, params
      @user.person(true).profile.tag_list.to_set.should == ['apples', 'oranges', 'pears'].to_set
    end

    it 'sets plaintext tags without #' do
      params = { :id => @user.person.id,
                 :tags => ',#apples,#oranges,',
                 :profile => {:tag_string => 'bananas'} }
      
      put :update, params
      @user.person(true).profile.tag_list.to_set.should == ['apples', 'oranges', 'bananas'].to_set
    end

    it 'sets valid birthday' do
      params = { :id => @user.person.id,
                 :profile => {
                   :date => {
                     :year => '2001',
                     :month => '02',
                     :day => '28' } } }

      put :update, params
      @user.person(true).profile.birthday.year.should == 2001
      @user.person(true).profile.birthday.month.should == 2
      @user.person(true).profile.birthday.day.should == 28
    end

    it 'displays error for invalid birthday' do
      params = { :id => @user.person.id,
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