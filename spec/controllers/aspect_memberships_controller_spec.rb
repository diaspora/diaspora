#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AspectMembershipsController do
  render_views

  before do
    @user  = alice
    @user2 = bob

    @aspect0  = @user.aspects.first
    @aspect1  = @user.aspects.create(:name => "another aspect")
    @aspect2  = @user2.aspects.first

    @contact = @user.contact_for(@user2.person)
    @user.getting_started = false
    @user.save
    sign_in :user, @user
    @controller.stub(:current_user).and_return(@user)
    request.env["HTTP_REFERER"] = 'http://' + request.host
  end

  describe '#create' do
    it 'creates an aspect membership' do
      @user.should_receive(:add_contact_to_aspect)
      post :create,
        :format => 'js',
        :person_id => @user2.person.id,
        :aspect_id => @aspect1.id
      response.should be_success
    end
  end


  describe "#destroy" do
    it 'removes contacts from an aspect' do
      @user.add_contact_to_aspect(@contact, @aspect1)
      delete :destroy,
        :format => 'js', :id => 123,
        :person_id => @user2.person.id,
        :aspect_id => @aspect0.id
      response.should be_success
      @aspect0.reload
      @aspect0.contacts.include?(@contact).should be false
    end

  describe "#update" do
    it 'calls the move_contact method' do
      @controller.stub!(:current_user).and_return(@user)
      @user.should_receive(:move_contact)
      put :update, :id => 123,
                   :person_id => @user.person.id,
                   :aspect_id => @aspect0.id,
                   :to => @aspect1.id
    end
  end

    context 'aspect membership does not exist' do
      it 'person does not exist' do
        delete :destroy,
          :format => 'js', :id => 123,
          :person_id => 4324525,
          :id => @aspect0.id
        response.should_not be_success
        response.body.should include "Could not find the selected person in that aspect"
      end

      it 'contact is not in the aspect' do
        delete :destroy,
          :format => 'js', :id => 123,
          :person_id => @user2.person.id,
          :aspect_id => 2321
        response.should_not be_success
        response.body.should include "Could not find the selected person in that aspect"
      end
    end

    it 'has the error of cannot delete contact from last aspect if its the last aspect' do
      delete :destroy,
        :format => 'js', :id => 123,
        :person_id => @user2.person.id,
        :aspect_id => @aspect0.id
      response.should_not be_success
      response.body.should include "Cannot remove person from last aspect"
    end
  end
end
