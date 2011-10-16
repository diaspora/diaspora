#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Api::V0::UsersController do
  describe '#show' do
    it 'succeeds' do
      get :show, :username => 'alice'
      response.should be_success
    end
    it "404s if there's no such user" do
      get :show, :username => "*****"
      response.should be_not_found
    end
    it "returns the public profile data" do
      get :show, :username => 'alice'
      parsed_json = JSON.parse(response.body)
      parsed_json.keys.should =~ %w( diaspora_id first_name last_name image_url searchable )
    end
  end
end
