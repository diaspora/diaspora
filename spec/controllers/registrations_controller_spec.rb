#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe RegistrationsController do
  include Devise::TestHelpers

  render_views

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#new" do
    it "succeeds" do
      get :new
      response.should be_success
    end
  end
end
