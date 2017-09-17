# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe AspectMembershipsController, type: :controller do
  before do
    @aspect0  = alice.aspects.first
    @aspect1  = alice.aspects.create(name: "another aspect")
    @aspect2  = bob.aspects.first

    @contact = alice.contact_for(bob.person)
    alice.getting_started = false
    alice.save
    sign_in alice, scope: :user
    allow(@controller).to receive(:current_user).and_return(alice)
    request.env["HTTP_REFERER"] = "http://" + request.host
  end

  describe "#create" do
    before do
      @person = eve.person
    end

    it "succeeds" do
      post :create, params: {person_id: bob.person.id, aspect_id: @aspect1.id}, format: :json
      expect(response).to be_success
    end

    it "creates an aspect membership" do
      expect {
        post :create, params: {person_id: bob.person.id, aspect_id: @aspect1.id}, format: :json
      }.to change {
        alice.contact_for(bob.person).aspect_memberships.count
      }.by(1)
    end

    it "creates a contact" do
      # argggg why?
      alice.contacts.reload
      expect {
        post :create, params: {person_id: @person.id, aspect_id: @aspect0.id}, format: :json
      }.to change {
        alice.contacts.size
      }.by(1)
    end

    it "does not 500 on a duplicate key error" do
      params = {person_id: @person.id, aspect_id: @aspect0.id}
      post :create, params: params, format: :json
      post :create, params: params, format: :json
      expect(response.status).to eq(400)
      expect(response.body).to eq(I18n.t("aspect_memberships.destroy.invalid_statement"))
    end

    context "json" do
      it "returns the aspect membership" do
        post :create, params: {person_id: @person.id, aspect_id: @aspect0.id}, format: :json

        contact = @controller.current_user.contact_for(@person)
        expect(response.body).to eq(AspectMembershipPresenter.new(contact.aspect_memberships.first).base_hash.to_json)
      end

      it "responds with an error message when the request failed" do
        expect(alice).to receive(:share_with).and_return(nil)
        post :create, params: {person_id: @person.id, aspect_id: @aspect0.id}, format: :json
        expect(response.status).to eq(409)
        expect(response.body).to eq(I18n.t("aspects.add_to_aspect.failure"))
      end
    end
  end

  describe "#destroy" do
    it "removes contacts from an aspect" do
      membership = alice.add_contact_to_aspect(@contact, @aspect1)
      delete :destroy, params: {id: membership.id}, format: :json
      expect(response).to be_success
      @aspect1.reload
      expect(@aspect1.contacts.to_a).not_to include @contact
    end

    it "aspect membership does not exist" do
      delete :destroy, params: {id: 123}, format: :json
      expect(response).not_to be_success
      expect(response.body).to eq(I18n.t("aspect_memberships.destroy.no_membership"))
    end
  end
end
