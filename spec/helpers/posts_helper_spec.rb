# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe PostsHelper, :type => :helper do

  describe '#post_page_title' do
    before do
      @sm = FactoryGirl.create(:status_message)
    end

    context 'with posts with text' do
      it "delegates to message.title" do
        message = double
        expect(message).to receive(:title)
        post = double(message: message)
        post_page_title(post)
      end
    end

    context "with a reshare" do
      it "returns 'Reshare of...'" do
        reshare = FactoryGirl.create(:reshare, author: alice.person)
        original_post = reshare.root
        expect(post_page_title(reshare)).to eq I18n.t("posts.show.reshare_of", post_link: link_to(post_page_title(original_post),
                 post_path(original_post),
                 data:  {ref: original_post.id},
                 class: "hard_object_link").html_safe)
      end
    end
  end


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
