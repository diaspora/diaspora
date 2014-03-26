#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PeopleController do
  describe '#index' do
    before do
      sign_in :user, bob
    end

    it "generates a jasmine fixture with no query", :fixture => true do
      get :index
      save_fixture(html_for("body"), "empty_people_search")
    end

    it "generates a jasmine fixture trying an external search", :fixture => true do
      get :index, :q => "sample@diaspor.us"
      save_fixture(html_for("body"), "pending_external_people_search")
    end
  end

  describe '#aspect_membership_dropdown' do
    before do
      aspect = bob.aspects.create name: 'Testing'
      bob.share_with alice.person, aspect
      sign_in :user, bob
    end

    it "generates a jasmine fixture using Blueprint", :fixture => true do
      get :aspect_membership_dropdown, :person_id => alice.person.guid
      save_fixture(html_for("body"), "aspect_membership_dropdown_blueprint")
    end

    it "generates a jasmine fixture using Bootstrap", :fixture => true do
      get :aspect_membership_dropdown, :person_id => alice.person.guid, :bootstrap => true
      save_fixture(html_for("body"), "aspect_membership_dropdown_bootstrap")
    end
  end
end
