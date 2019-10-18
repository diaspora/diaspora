# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe ContactsController, :type => :controller do
  describe '#index' do
    before do
      @aspect = bob.aspects.create(:name => "another aspect")
      bob.share_with alice.person, @aspect
      bob.share_with eve.person, @aspect
      sign_in bob, scope: :user
    end

    it "generates the aspects_manage fixture", :fixture => true do
      get :index, params: {a_id: @aspect.id}
      save_fixture(html_for("body"), "aspects_manage")
    end

    it "generates the aspects_manage_contacts_json fixture", fixture: true do
      # adds one not mutual contact
      bob.share_with(FactoryGirl.create(:person), @aspect)

      get :index, params: {a_id: @aspect.id, page: "1"}, format: :json
      save_fixture(response.body, "aspects_manage_contacts_json")
    end

    it "generates the contacts_json fixture", :fixture => true do
      json = bob.contacts.map { |c|
               ContactPresenter.new(c, bob).full_hash_with_person
             }.to_json
      save_fixture(json, "contacts_json")
    end
  end
end
