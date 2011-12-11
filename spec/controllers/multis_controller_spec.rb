#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe MultisController do
  describe '#index' do
    before do
      @old_spotlight_value = AppConfig[:community_spotlight]
      sign_in :user, alice
    end

    after do
      AppConfig[:community_spotlight] = @old_spotlight_value
    end

    describe 'jasmine fixtures' do
      it 'generate' do
        status_message = alice.post(:status_message, :text => "hey", :to => alice.aspects.first.id)
        get :index, :format => :json
        save_fixture(response.body, "multi_stream_json")
      end
    end

    it 'succeeds' do
      AppConfig[:community_spotlight] = [bob.person.diaspora_handle]
      get :index
      response.should be_success
    end

    it 'succeeds without AppConfig[:community_spotlight]' do
      AppConfig[:community_spotlight] = nil
      get :index
      response.should be_success
    end
  end
end
