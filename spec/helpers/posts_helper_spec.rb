#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PostsHelper, :type => :helper do

  describe '#post_iframe_url' do
    before do
      @post = FactoryGirl.create(:status_message)
    end

    it "returns an iframe tag" do
      expect(post_iframe_url(@post.id)).to include "iframe"
    end

    it "returns an iframe containing the post" do
      expect(post_iframe_url(@post.id)).to include "src='#{AppConfig.url_to(post_path(@post))}'"
    end
  end
end
