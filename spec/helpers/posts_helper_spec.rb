#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PostsHelper do
  describe '#post_iframe_url' do
    before do
      @post = FactoryGirl.create(:status_message)
    end

    it "returns an iframe tag" do
      post_iframe_url(@post.id).should include "iframe"
    end

    it "returns an iframe containing the post" do
      post_iframe_url(@post.id).should include "src='http://localhost:9887#{post_path(@post)}'"
    end
  end
end
