#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AspectMembershipsController, :type => :controller do
  before do
    @aspect0  = alice.aspects.first
    @aspect1  = alice.aspects.create(:name => "another aspect")
    @aspect2  = bob.aspects.first

    @contact = alice.contact_for(bob.person)
    alice.getting_started = false
    alice.save
    sign_in :user, alice
    allow(@controller).to receive(:current_user).and_return(alice)
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
      expect(response).to be_success
    end

    it 'creates an aspect membership' do
      expect {
        post :create,
          :format => :json,
          :person_id => bob.person.id,
          :aspect_id => @aspect1.id
      }.to change{
        alice.contact_for(bob.person).aspect_memberships.count
      }.by(1)
    end

    it 'creates a contact' do
      #argggg why?
      alice.contacts.reload
      expect {
        post :create,
          :format => :json,
          :person_id => @person.id,
          :aspect_id => @aspect0.id
      }.to change{
        alice.contacts.size
      }.by(1)
    end

    it 'failure flashes error' do
      expect(alice).to receive(:share_with).and_return(nil)
      post :create,
        :format => :json,
        :person_id => @person.id,
        :aspect_id => @aspect0.id
      expect(flash[:error]).not_to be_blank
    end

    it 'does not 500 on a duplicate key error' do
      params = {:format => :json, :person_id => @person.id, :aspect_id => @aspect0.id}
      post :create, params
      post :create, params
      expect(response.status).to eq(400)
    end

    context 'json' do
      it 'returns a list of aspect ids for the person' do
        post :create,
        :format => :json,
        :person_id => @person.id,
        :aspect_id => @aspect0.id

        contact = @controller.current_user.contact_for(@person)
        expect(response.body).to eq(contact.aspect_memberships.first.to_json)
      end
    end
  end

  describe "#destroy" do
    it 'removes contacts from an aspect' do
      membership = alice.add_contact_to_aspect(@contact, @aspect1)
      delete :destroy, :format => :json, :id => membership.id
      expect(response).to be_success
      @aspect1.reload
      expect(@aspect1.contacts.to_a).not_to include @contact
    end

    it 'does not 500 on an html request' do
      membership = alice.add_contact_to_aspect(@contact, @aspect1)
      delete :destroy, :id => membership.id
      expect(response).to redirect_to :back
      @aspect1.reload
      expect(@aspect1.contacts.to_a).not_to include @contact
    end

    it 'aspect membership does not exist' do
      delete :destroy, :format => :json, :id => 123
      expect(response).not_to be_success
      expect(response.body).to include "Could not find the selected person in that aspect"
    end
  end
end
