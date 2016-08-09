#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ContactsController, :type => :controller do
  before do
    sign_in :user, bob
    allow(@controller).to receive(:current_user).and_return(bob)
  end

  describe '#index' do
    context 'format mobile' do
      it "succeeds" do
        get :index, :format => 'mobile'
        expect(response).to be_success
      end
    end

    context 'format html' do
      it "succeeds" do
        get :index
        expect(response).to be_success
      end

      it "assigns contacts" do
        get :index
        contacts = assigns(:contacts)
        expect(contacts.to_set).to eq(bob.contacts.to_set)
      end

      it "shows only contacts a user is sharing with" do
        contact = bob.contacts.first
        contact.update_attributes(:sharing => false)

        get :index
        contacts = assigns(:contacts)
        expect(contacts.to_set).to eq(bob.contacts.receiving.to_set)
      end

      it "shows all contacts (sharing and receiving)" do
        contact = bob.contacts.first
        contact.update_attributes(:sharing => false)

        get :index, :set => "all"
        contacts = assigns(:contacts)
        expect(contacts.to_set).to eq(bob.contacts.to_set)
      end
    end
  end

  describe "#search" do
    before do
      @eugene = FactoryGirl.create(:person, profile: FactoryGirl.build(:profile, first_name: "Eugene", last_name: "W"))
      bob.share_with(@eugene, bob.aspects.first)
      @casey = FactoryGirl.create(:person, profile: FactoryGirl.build(:profile, first_name: "Casey", last_name: "W"))
    end

    describe "via json" do
      it "succeeds" do
        get :search, q: "Eugene", format: "json"
        expect(response).to be_success
      end

      it "responds with json" do
        get :search, q: "Eugene", format: "json"
        expect(response.body).to eq([@eugene].to_json)
      end

      it "only returns contacts" do
        get :search, q: "Casey", format: "json"
        expect(response.body).to eq([].to_json)
      end
    end
  end

  describe '#spotlight' do
    it 'succeeds' do
      get :spotlight
      expect(response).to be_success
    end

    it 'gets queries for users in the app config' do
      Role.add_spotlight(alice.person)

      get :spotlight
      expect(assigns[:people]).to eq([alice.person])
    end
  end
end
