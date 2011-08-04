#   Copyright (c) 2010, Diaspora Inc.  This file is
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

    it 'will return the contacts for multiple aspects' do
      get :index, :aspect_ids => bob.aspect_ids, :format => 'json'
      assigns[:people].should == bob.contacts.map(&:person)
      response.should be_success
    end

    it "generates a jasmine fixture", :fixture => true do
      get :index
      save_fixture(html_for("body"), "aspects_manage")
    end
  end

  describe '#featured' do
    it 'succeeds' do
      get :featured
      response.should be_success
    end

    it 'gets queries for users in the app config' do
      AppConfig[:featured_users] = [alice.diaspora_handle]

      get :featured
      assigns[:people].should == [alice.person]
    end
  end
end
