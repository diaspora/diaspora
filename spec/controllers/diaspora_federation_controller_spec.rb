#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "spec_helper"

# this is temporarily needed for fixture generation
# TODO: remove this after the parsing is also in the diaspora_federation gem
describe DiasporaFederation do
  routes { DiasporaFederation::Engine.routes }

  let(:fixture_path) { Rails.root.join("spec", "fixtures") }

  describe DiasporaFederation::WebfingerController, type: :controller do
    it "generates the host_meta fixture", fixture: true do
      get :host_meta
      expect(response).to be_success
      expect(response.body).to match(/webfinger/)
      save_fixture(response.body, "host-meta", fixture_path)
    end

    it "generates the webfinger fixture", fixture: true do
      post :legacy_webfinger, "q" => alice.person.diaspora_handle
      expect(response).to be_success
      save_fixture(response.body, "webfinger", fixture_path)
    end
  end

  describe DiasporaFederation::HCardController, type: :controller do
    it "generates the hCard fixture", fixture: true do
      post :hcard, "guid" => alice.person.guid.to_s
      expect(response).to be_success
      save_fixture(response.body, "hcard", fixture_path)
    end
  end
end
