# Copyright (c) 2010-2011, Diaspora Inc. This file is
# licensed under the Affero General Public License version 3 or later. See
# the COPYRIGHT file.

require 'spec_helper'

describe LikeStreamController do
  before do
    sign_in :user, alice
  end

  describe 'index' do
    it 'succeeds' do
      get :index
      response.should be_success
    end

    it 'assigns a stream' do
      get :index
      assigns[:stream].should be_a Stream::Likes
    end
  end
end
