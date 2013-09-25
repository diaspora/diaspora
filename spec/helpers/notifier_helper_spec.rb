#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe NotifierHelper do
  include MarkdownifyHelper

  describe '#post_message' do
    before do
      # post for truncate test
      @post = FactoryGirl.create(:status_message)
      @post.text = "hi dude! "*10
      @truncated_post = "hi dude! hi dude! hi dude! hi dude! hi dude! hi dude! hi dude! hi dude! hi du..."
      # post for markdown test
      @markdown_post = FactoryGirl.create(:status_message)
      @markdown_post.text = "[link](http://diasporafoundation.org) **bold text** *other text*"
      @striped_markdown_post = "link bold text other text"
    end

    it 'truncates in the post' do
      opts = {:length => @post.text.length - 10}
      post_message(@post, opts).should == @truncated_post
    end

    it 'strip markdown in the post' do
      opts = {:length => @markdown_post.text.length}
      post_message(@markdown_post, opts).should == @striped_markdown_post
    end
  end

  describe '#comment_message' do
    before do
      # comment for includes a link test
      @comment = FactoryGirl.create(:comment)
      @post_comment_url = I18n.t('notifier.comment_on_post.post', post: post_comment_url(@comment.post, @comment))
    end

    it 'includes a link to the post' do
      comment_message(@comment).should == @post_comment_url
    end

    it 'does not include text' do
      comment_message(@comment).should_not include @comment.text
    end
  end

end
