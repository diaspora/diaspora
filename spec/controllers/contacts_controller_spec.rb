#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ContactsController do
  before do
    sign_in :user, bob
    @controller.stub(:current_user).and_return(bob)
  end

  describe '#sharing' do
    it "succeeds" do
      get :sharing
      response.should be_success
    end

    it 'eager loads the aspects' do
      get :sharing
      assigns[:contacts].first.aspect_memberships.loaded?.should be_true
    end

    it "assigns only the people sharing with you with 'share_with' flag" do
      get :sharing, :id => 'share_with'
      assigns[:contacts].to_set.should == bob.contacts.sharing.to_set
    end
  end

  describe '#index' do
    context 'format mobile' do
      it "succeeds" do
        get :index, :format => 'mobile'
        response.should be_success
      end
    end

    context 'format html' do
      it "succeeds" do
        get :index
        response.should be_success
      end

      it "assigns contacts" do
        get :index
        contacts = assigns(:contacts)
        contacts.to_set.should == bob.contacts.to_set
      end

      it "shows only contacts a user is sharing with" do
        contact = bob.contacts.first
        contact.update_attributes(:sharing => false)

        get :index, :set => "mine"
        contacts = assigns(:contacts)
        contacts.to_set.should == bob.contacts.receiving.to_set
      end

      it "shows all contacts (sharing and receiving)" do
        contact = bob.contacts.first
        contact.update_attributes(:sharing => false)

        get :index, :set => "all"
        contacts = assigns(:contacts)
        contacts.to_set.should == bob.contacts.to_set
      end
    end

    context 'format json' do
      it 'assumes all aspects if none are specified' do
        get :index, :format => 'json'
        assigns[:people].map(&:id).should =~ bob.contacts.map { |c| c.person.id }
        response.should be_success
      end

      it 'returns the contacts for multiple aspects' do
        get :index, :aspect_ids => bob.aspect_ids, :format => 'json'
        assigns[:people].map(&:id).should =~ bob.contacts.map { |c| c.person.id }
        response.should be_success
      end

      it 'does not return duplicate contacts' do
        aspect = bob.aspects.create(:name => 'hilarious people')
        aspect.contacts << bob.contact_for(eve.person)
        get :index, :format => 'json', :aspect_ids => bob.aspect_ids
        assigns[:people].map { |p| p.id }.uniq.should == assigns[:people].map { |p| p.id }
        assigns[:people].map(&:id).should =~ bob.contacts.map { |c| c.person.id }
      end
    end
  end

  describe '#spotlight' do
    it 'succeeds' do
      get :spotlight
      response.should be_success
    end

    it 'gets queries for users in the app config' do
      Role.add_spotlight(alice.person)

      get :spotlight
      assigns[:people].should == [alice.person]
    end
  end
end
