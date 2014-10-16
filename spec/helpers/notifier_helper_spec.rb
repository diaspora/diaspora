#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe NotifierHelper, :type => :helper do
  describe '#post_message' do
    before do
      # post for truncate test
      @post = FactoryGirl.create(:status_message, text: "hi dude! "*10)
      @truncated_post = "hi dude! hi dude! hi dude! hi dude! hi dude! hi dude! hi dude! hi dude! hi du..."
      # post for markdown test
      @markdown_post = FactoryGirl.create(:status_message,
        text: "[link](http://diasporafoundation.org) **bold text** *other text*")
      @striped_markdown_post = "link (http://diasporafoundation.org) bold text other text"
    end

    it 'truncates in the post' do
      opts = {:length => @post.text.length - 10}
      expect(post_message(@post, opts)).to eq(@truncated_post)
    end

    it 'strip markdown in the post' do
      opts = {:length => @markdown_post.text.length}
      expect(post_message(@markdown_post, opts)).to eq(@striped_markdown_post)
    end
  end

  describe '#comment_message' do
    before do
      # comment for truncate test
      @comment = FactoryGirl.create(:comment)
      @comment.text = "hi dude! "*10
      @truncated_comment = "hi dude! hi dude! hi dude! hi dude! hi dude! hi dude! hi dude! hi dude! hi d..."
      # comment for markdown test
      @markdown_comment = FactoryGirl.create(:comment)
      @markdown_comment.text = "[link](http://diasporafoundation.org) **bold text** *other text*"
      @striped_markdown_comment = "link (http://diasporafoundation.org) bold text other text"
    end

    it 'truncates in the comment' do
      opts = {:length => @comment.text.length - 10}
      expect(comment_message(@comment, opts)).to eq(@truncated_comment)
    end

    it 'strip markdown in the comment' do
      opts = {:length => @markdown_comment.text.length}
      expect(comment_message(@markdown_comment, opts)).to eq(@striped_markdown_comment)
    end
  end
end
