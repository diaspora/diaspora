# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe StatusMessagesController, :type => :controller do
  describe '#bookmarklet' do
    before do
      sign_in bob, scope: :user
    end

    it "generates a jasmine fixture", :fixture => true do
      get :bookmarklet
      save_fixture(html_for("body"), "bookmarklet")
    end

  end

  describe '#new' do
    before do
      sign_in alice, scope: :user
    end

    it 'generates a jasmine fixture', :fixture => true do
      contact = alice.contact_for(bob.person)
      aspect = alice.aspects.create(:name => 'people')
      contact.aspects << aspect
      contact.save
      get :new, params: {person_id: bob.person.id}
      save_fixture(html_for("body"), "status_message_new")
    end
  end
end
