# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe ContactsController, :type => :controller do
  before do
    sign_in bob, scope: :user
    allow(@controller).to receive(:current_user).and_return(bob)
  end

  describe '#index' do
    context 'format mobile' do
      it "succeeds" do
        get :index, format: :mobile
        expect(response).to be_successful
      end
    end

    context 'format html' do
      it "succeeds" do
        get :index
        expect(response).to be_successful
      end

      it "doesn't assign contacts" do
        get :index
        contacts = assigns(:contacts)
        expect(contacts).to be_nil
      end
    end

    context "format json" do
      context "for the contacts search" do
        before do
          @person1 = FactoryGirl.create(:person)
          bob.share_with(@person1, bob.aspects.first)
          @person2 = FactoryGirl.create(:person)
          @person3 = FactoryGirl.create(:person)
          bob.contacts.create(person: @person3, aspects: [bob.aspects.first], receiving: true, sharing: true)
        end

        it "succeeds" do
          get :index, params: {q: @person1.first_name}, format: :json
          expect(response).to be_successful
        end

        it "responds with json" do
          get :index, params: {q: @person1.first_name}, format: :json
          expect(response.body).to eq([@person1].to_json)
        end

        it "only returns contacts" do
          get :index, params: {q: @person2.first_name}, format: :json
          expect(response.body).to eq([].to_json)
        end

        it "only returns mutual contacts when mutual parameter is true" do
          get :index, params: {q: @person1.first_name, mutual: true}, format: :json
          expect(response.body).to eq([].to_json)
          get :index, params: {q: @person2.first_name, mutual: true}, format: :json
          expect(response.body).to eq([].to_json)
          get :index, params: {q: @person3.first_name, mutual: true}, format: :json
          expect(response.body).to eq([@person3].to_json)
        end
      end

      context "for pagination on the contacts page" do
        context "without parameters" do
          it "returns contacts" do
            get :index, params: {page: "1"}, format: :json
            contact_ids = JSON.parse(response.body).map {|c| c["id"] }
            expect(contact_ids.to_set).to eq(bob.contacts.map(&:id).to_set)
          end

          it "returns only contacts which are receiving (the user is sharing with them)" do
            contact = bob.contacts.first
            contact.update_attributes(receiving: false)

            get :index, params: {params: {page: "1"}}, format: :json
            contact_ids = JSON.parse(response.body).map {|c| c["id"] }
            expect(contact_ids.to_set).to eq(bob.contacts.receiving.map(&:id).to_set)
            expect(contact_ids).not_to include(contact.id)
          end
        end

        context "set: all" do
          before do
            contact = bob.contacts.first
            contact.update_attributes(receiving: false)
          end

          it "returns all contacts (sharing and receiving)" do
            get :index, params: {page: "1", set: "all"}, format: :json
            contact_ids = JSON.parse(response.body).map {|c| c["id"] }
            expect(contact_ids.to_set).to eq(bob.contacts.map(&:id).to_set)
          end

          it "sorts contacts by receiving status" do
            get :index, params: {page: "1", set: "all"}, format: :json
            contact_ids = JSON.parse(response.body).map {|c| c["id"] }
            expect(contact_ids).to eq(bob.contacts.order("receiving DESC").map(&:id))
            expect(contact_ids.last).to eq(bob.contacts.first.id)
          end
        end

        context "with an aspect id" do
          before do
            @aspect = bob.aspects.create(name: "awesome contacts")
            @person = FactoryGirl.create(:person)
            bob.share_with(@person, @aspect)
          end

          it "returns all contacts" do
            get :index, params: {a_id: @aspect.id, page: "1"}, format: :json
            contact_ids = JSON.parse(response.body).map {|c| c["id"] }
            expect(contact_ids.to_set).to eq(bob.contacts.map(&:id).to_set)
          end

          it "sorts contacts by aspect memberships" do
            get :index, params: {a_id: @aspect.id, page: "1"}, format: :json
            expect(JSON.parse(response.body).first["person"]["id"]).to eq(@person.id)

            get :index, params: {a_id: bob.aspects.first.id, page: "1"}, format: :json
            expect(JSON.parse(response.body).first["person"]["id"]).not_to eq(@person.id)
          end
        end
      end
    end
  end

  describe '#spotlight' do
    it 'succeeds' do
      get :spotlight
      expect(response).to be_successful
    end

    it 'gets queries for users in the app config' do
      Role.add_spotlight(alice.person)

      get :spotlight
      expect(assigns[:people]).to eq([alice.person])
    end
  end
end
