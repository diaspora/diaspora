#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe NotifierHelper, :type => :helper do
  describe '#post_message' do
    before do
      # post for markdown test
      @markdown_post = FactoryGirl.create(:status_message,
        text: "[link](http://diasporafoundation.org) **bold text** *other text*", public: true)
      @striped_markdown_post = "link (http://diasporafoundation.org) bold text other text"
      
      @limited_post = FactoryGirl.create(:status_message, text: "This is top secret post. Shhhhhhhh!!!", public: false)
    end
    
    it 'strip markdown in the post' do
      expect(post_message(@markdown_post)).to eq(@striped_markdown_post)
    end

    it 'hides the private content' do
      expect(post_message(@limited_post)).not_to include("secret post")
    end
  end

  describe '#comment_message' do
    before do
      # comment for markdown test
      @markdown_comment = FactoryGirl.create(:comment)
      @markdown_comment.post.public = true
      @markdown_comment.text = "[link](http://diasporafoundation.org) **bold text** *other text*"
      @striped_markdown_comment = "link (http://diasporafoundation.org) bold text other text"
      
      # comment for limited post
      @limited_comment = FactoryGirl.create(:comment)
      @limited_comment.post.public = false
      @limited_comment.text = "This is top secret comment. Shhhhhhhh!!!"
    end
    
    it 'strip markdown in the comment' do
      expect(comment_message(@markdown_comment)).to eq(@striped_markdown_comment)
    end
    
    it 'hides the private content' do
      expect(comment_message(@limited_comment)).not_to include("secret comment")
    end
  end
end
