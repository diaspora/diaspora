#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe HomeController do
  describe '#show' do
    it 'does not redirect' do
      sign_out :user
      get :show
      response.should_not be_redirect
    end

    context 'redirection'
      before do
        sign_in alice
      end

      it 'points to the stream if a user has contacts' do
        get :show, :home => true
        response.should redirect_to(stream_path)
      end

      it "points to a user's profile page if a user is an admin without contacts" do
        alice.contacts.destroy_all
        Role.add_admin(alice.person)
        get :show, :home => true
        response.should redirect_to(person_path(alice.person))
      end

      it "points to the root_path if a user is an admin without contacts" do
        alice.contacts.destroy_all
        Role.add_beta(alice.person)
        get :show, :home => true
        response.should redirect_to(person_path(alice.person))
      end
  end
end
