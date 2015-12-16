#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ContactsController, :type => :controller do
  describe '#index' do
    before do
      AppConfig.chat.enabled = true
      @aspect = bob.aspects.create(:name => "another aspect")
      bob.share_with alice.person, @aspect
      bob.share_with eve.person, @aspect
      sign_in :user, bob
    end

    it "generates the aspects_manage fixture", :fixture => true do
      get :index, :a_id => @aspect.id
      save_fixture(html_for("body"), "aspects_manage")
    end

    it "generates the contacts_json fixture", :fixture => true do
      json = bob.contacts.map { |c|
               ContactPresenter.new(c, bob).full_hash_with_person
             }.to_json
      save_fixture(json, "contacts_json")
    end
  end
end
