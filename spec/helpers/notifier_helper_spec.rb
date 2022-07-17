# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe NotifierHelper, :type => :helper do
  describe "#post_message" do
    before do
      # post for markdown test
      @markdown_post = FactoryBot.create(:status_message,
                                         text:   "[link](https://diasporafoundation.org) **bold text** *other text*",
                                         public: true)
      @striped_markdown_post = "link (https://diasporafoundation.org) bold text other text"
    end

    it "strip markdown in the post" do
      expect(post_message(@markdown_post)).to eq(@striped_markdown_post)
    end

    it "renders markdown as html" do
      expect(post_message(@markdown_post, html: true)).to include("<a href=\"https://diasporafoundation.org\">link</a>")
    end

    it "falls back to the title if the post has no text" do
      photo = FactoryBot.build(:photo, public: true)
      photo_post = FactoryBot.build(:status_message, author: photo.author, text: "", photos: [photo], public: true)
      expect(helper.post_message(photo_post))
        .to eq(I18n.t("posts.show.photos_by", count: 1, author: photo_post.author_name))
    end

    it "falls back to the title, if the root post was deleted" do
      reshare = FactoryBot.create(:reshare)
      reshare.root.destroy
      expect(helper.post_message(Reshare.find(reshare.id)))
        .to eq(I18n.t("posts.show.reshare_by", author: reshare.author_name))
    end
  end

  describe "#comment_message" do
    before do
      # comment for markdown test
      @markdown_comment = FactoryBot.create(:comment)
      @markdown_comment.post.public = true
      @markdown_comment.text = "[link](https://diasporafoundation.org) **bold text** *other text*"
      @striped_markdown_comment = "link (https://diasporafoundation.org) bold text other text"

      # comment for limited post
      @limited_comment = FactoryBot.create(:comment)
      @limited_comment.post.public = false
      @limited_comment.text = "This is top secret comment. Shhhhhhhh!!!"
    end

    it "strip markdown in the comment" do
      expect(comment_message(@markdown_comment)).to eq(@striped_markdown_comment)
    end

    it "renders markdown as html" do
      expect(comment_message(@markdown_comment, html: true))
        .to include("<a href=\"https://diasporafoundation.org\">link</a>")
    end

    it "hides the private content" do
      expect(comment_message(@limited_comment)).not_to include("secret comment")
    end
  end
end
