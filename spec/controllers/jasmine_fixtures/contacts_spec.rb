#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ContactsController, :type => :controller do
  describe '#index' do
    before do
      @aspect = bob.aspects.create(:name => "another aspect")
      bob.share_with alice.person, @aspect
      sign_in :user, bob
    end

    it "generates a jasmine fixture", :fixture => true do
      get :index, :a_id => @aspect.id
      save_fixture(html_for("body"), "aspects_manage")
    end
  end
end
