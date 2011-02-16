#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


require 'spec_helper'

describe ContactsController do
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

  describe 'new' do

    it 'succeeds' do
      pending "This is going to be new request"
      get :new
      response.should be_success
    end
  end

  describe 'create' do
    context 'with an incoming request' do
      before do
        @user3 = Factory.create(:user)
        @user3.send_contact_request_to(@user.person, @user3.aspects.create(:name => "Walruses"))
      end
      it 'deletes the request' do
        post :create,
          :format => 'js',
          :person_id => @user3.person.id,
          :aspect_id => @aspect1.id
        Request.where(:sender_id => @user3.person.id, :recipient_id => @user.person.id).first.should be_nil
      end
      it 'does not leave the contact pending' do
        post :create,
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
        post :create,
          :format => 'js',
          :person_id => @person.id,
          :aspect_id => @aspect1.id
      end
      it 'does not call add_contact_to_aspect' do
        @user.should_not_receive(:add_contact_to_aspect)
        post :create,
          :format => 'js',
          :person_id => @person.id,
          :aspect_id => @aspect1.id
      end
    end
  end
end
