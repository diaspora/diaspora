#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AspectMembershipsController do
  before do
    @aspect0  = alice.aspects.first
    @aspect1  = alice.aspects.create(:name => "another aspect")
    @aspect2  = bob.aspects.first

    @contact = alice.contact_for(bob.person)
    alice.getting_started = false
    alice.save
    sign_in :user, alice
    @controller.stub(:current_user).and_return(alice)
    request.env["HTTP_REFERER"] = 'http://' + request.host
  end

  describe '#create' do
    before do
      @person = eve.person
    end

    it 'succeeds' do
      post :create,
        :format => :json,
        :person_id => bob.person.id,
        :aspect_id => @aspect1.id
      response.should be_success
    end

    it 'creates an aspect membership' do
      lambda {
        post :create,
          :format => :json,
          :person_id => bob.person.id,
          :aspect_id => @aspect1.id
      }.should change{
        alice.contact_for(bob.person).aspect_memberships.count
      }.by(1)
    end

    it 'creates a contact' do
      #argggg why?
      alice.contacts.reload
      lambda {
        post :create,
          :format => :json,
          :person_id => @person.id,
          :aspect_id => @aspect0.id
      }.should change{
        alice.contacts.size
      }.by(1)
    end

    it 'failure flashes error' do
      alice.should_receive(:share_with).and_return(nil)
      post :create,
        :format => :json,
        :person_id => @person.id,
        :aspect_id => @aspect0.id
      flash[:error].should_not be_blank
    end

    it 'does not 500 on a duplicate key error' do
      params = {:format => :json, :person_id => @person.id, :aspect_id => @aspect0.id}
      post :create, params
      post :create, params
      response.status.should == 400
    end

    context 'json' do
      it 'returns a list of aspect ids for the person' do
        post :create,
        :format => :json,
        :person_id => @person.id,
        :aspect_id => @aspect0.id

        contact = @controller.current_user.contact_for(@person)
        response.body.should == contact.aspect_memberships.first.to_json
      end
    end
  end

  describe "#destroy" do
    it 'removes contacts from an aspect' do
      membership = alice.add_contact_to_aspect(@contact, @aspect1)
      delete :destroy, :format => :json, :id => membership.id
      response.should be_success
      @aspect1.reload
      @aspect1.contacts.to_a.should_not include @contact
    end

    it 'does not 500 on an html request' do
      membership = alice.add_contact_to_aspect(@contact, @aspect1)
      delete :destroy, :id => membership.id
      response.should redirect_to :back
      @aspect1.reload
      @aspect1.contacts.to_a.should_not include @contact
    end

    it 'aspect membership does not exist' do
      delete :destroy, :format => :json, :id => 123
      response.should_not be_success
      response.body.should include "Could not find the selected person in that aspect"
    end
  end
end
