#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe NotifierHelper do
  include MarkdownifyHelper
  
  describe '#comment_message' do
    before do
      @comment = FactoryGirl.create(:comment)
    end

    it 'truncates the comment' do
      opts = {:length => 2}
      comment_message(@comment, opts).should == truncate(@comment.text, opts)
    end
  end
end
