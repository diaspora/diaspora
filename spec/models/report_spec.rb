#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Report do
  before do
    #:report => { :post_id => @message.id, :post_type => 'post', :text => 'offensive content' }
    @valid_post = {
      :post_id => 666,
      :post_type => 'post',
      :text => 'offensive content'
    }
    @valid_comment = {
      :post_id => 666,
      :post_type => 'comment',
      :text => 'offensive content'
    }
  end

  describe '#validation' do
    it 'validates that post ID is required' do
      bob.reports.build(:post_type => 'post', :text => 'blub').should_not be_valid
    end
    
    it 'validates that post type is required' do
      bob.reports.build(:post_id => 666, :text => 'blub').should_not be_valid
    end

    it 'validates that entry does not exist' do
      bob.reports.build(@valid_post).should be_valid
    end
    
    it 'validates that entry does exist' do
      bob.reports.create(@valid_post)
      bob.reports.build(@valid_post).should_not be_valid
    end
  end
end
