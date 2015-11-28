#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "spec_helper"

describe CommentsController, type: :controller do
  describe "#comments" do
    before do
      sign_in :user, alice
    end

    context "jasmine fixtures" do
      it "generates a jasmine fixture with the mobile comment box", fixture: true do
        get :new, format: :mobile, post_id: 1
        save_fixture(html_for("div"), "comments_mobile_commentbox")
      end
    end
  end
end
