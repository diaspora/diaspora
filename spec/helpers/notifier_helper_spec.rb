#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe NotifierHelper do
  include MarkdownifyHelper

  describe '#post_message' do
    before do
      # post for markdown test
      @markdown_post = FactoryGirl.create(:status_message)
      @markdown_post.text = "[link](http://diasporafoundation.org) **bold text** *other text*"
      @striped_markdown_post = "link bold text other text"
    end

    it 'strip markdown in the post' do
      opts = {:length => @markdown_post.text.length}
      post_message(@markdown_post, opts).should == @striped_markdown_post
    end
  end

  describe '#comment_message' do
    before do
      # comment for markdown test
      @markdown_comment = FactoryGirl.create(:comment)
      @markdown_comment.text = "[link](http://diasporafoundation.org) **bold text** *other text*"
      @striped_markdown_comment = "link bold text other text"
    end

    it 'strip markdown in the comment' do
      opts = {:length => @markdown_comment.text.length}
      comment_message(@markdown_comment, opts).should == @striped_markdown_comment
    end
  end
end
