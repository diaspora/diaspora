#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe CommentsController do
  describe '#index' do
    before do
      sign_in :user, alice
    end

    it 'generates a jasmine fixture', :fixture => true do
      aspect_to_post = bob.aspects.where(:name => "generic").first
      message = bob.post(:status_message, :text => "hey", :to => aspect_to_post.id)

      2.times do
        alice.comment("hey", :post => message)
      end

      get :index, :post_id => message.id
      save_fixture(response.body, "ajax_comments_on_post")
    end
  end

end
