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

  describe '#new' do
    it 'assigns a person' do
      get :new, :person_id => @user2.person.id
      assigns[:person].should == @user2.person
    end

    it 'assigns aspects without person' do
      get :new, :person_id => @user2.person.id
      assigns[:aspects_without_person].should =~ @user.aspects
    end
  end

  describe '#create' do

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

      it 'failure flashes error' do
        @controller.should_receive(:request_to_aspect).and_return(nil)
        post :create,
          :format => 'js',
          :person_id => @person.id,
          :aspect_id => @aspect1.id
        flash[:error].should_not be_empty
      end
    end
  end

  describe '#edit' do
    it 'assigns a contact' do
      get :edit, :id => @contact.id
      assigns[:contact].should == @contact
    end
    
    it 'assigns a person' do
      get :edit, :id => @contact.id
      assigns[:person].should == @contact.person
    end
  end

  describe '#destroy' do
    it 'disconnects from the person' do
      @user.should_receive(:disconnect).with(@contact)
      delete :destroy, :id => @contact.id
    end
    
    it 'flases success if the contact is not destroyed' do
      @user.stub!(:disconnect).and_return(true)
      delete :destroy, :id => @contact.id
      flash[:notice].should_not be_empty
    end

    it 'flases failure if the contact is not destroyed' do
      @user.stub!(:disconnect).and_return(false)
      delete :destroy, :id => @contact.id
      flash[:error].should_not be_empty
    end

    it 'redirects back to the person page' do
      delete :destroy, :id => @contact.id
      response.should redirect_to(@contact.person)
    end
  end
end
