#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe NotificationsController do
  describe '#notifications' do
    before do
      sign_in :user, alice
    end

    context 'jasmine fixtures' do
      before do
      end

      it "generates a jasmine fixture of two notifications", :fixture => true do
        post = Factory(:status_message)

        Factory(:notification, :recipient => alice, :target => post)
        Factory(:notification, :recipient => alice, :target => post)
        get :index
        save_fixture( html_for("body"), "notifications_index")
      end
      it "generates a jasmine fixture of with a start sharing notifcation from a contact", :fixture => true do
        post = Factory(:status_message)
        eve.share_with(alice.person, eve.aspects.first)
        Factory(:notification, :recipient => alice, :target => post)
        Factory(:notification, :recipient => alice, :target => post)

        get :index
        save_fixture(html_for("body"), "notifications_index_with_sharing")
      end

    end
  end
end
