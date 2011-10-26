#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, "spec", "shared_behaviors", "log_override")

describe HomeController do
  describe '#show' do
    it 'does not redirect' do
      get :show
      response.should_not be_redirect
    end

    it 'redirects to multis index if user is logged in' do
      sign_in alice
      get :show, :home => true
      response.should redirect_to(multi_path)
    end

    describe "custom logging on success" do
      before do
        @action = :show
        @action_params = {"lasers" => "green"}
      end

      it_should_behave_like "it overrides the logs on success"
    end

    describe "custom logging on redirect" do
      before do
        sign_in :user, bob
        @action = :show
        @action_params = {"lasers" => "green"}
      end

      it_should_behave_like "it overrides the logs on redirect"
    end
  end
end
