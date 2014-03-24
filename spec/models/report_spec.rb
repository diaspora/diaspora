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
    @report_post = bob.reports.new(@valid_post)
    @report_comment = bob.reports.new(@valid_comment)
  end

  describe '#validation' do
    it 'validates that post ID is required' do
      report = bob.reports.new(:post_type => 'post', :text => 'blub')
      report.save.should_not be_true
    end
    
    it 'validates that post type is required' do
      report = bob.reports.new(:post_id => 666, :text => 'blub')
      report.save.should_not be_true
    end
  end
  
  describe '#insert' do  
    it 'post successfully' do
      @report_post.save.should be_true
    end

    it 'comment successfully' do
      @report_comment.save.should be_true
    end
  end

  describe '#delete' do
    it 'post' do
      @report_post.destroy_reported_item.should be_true
    end

    it 'comment' do
      @report_comment.destroy_reported_item.should be_true
    end
  end

  describe '.check_database' do
    it 'post' do
      Report.where(:reviewed => true, :post_id => 666, :post_type => 'post').should be_true
    end

    it 'comment' do
      Report.where(:reviewed => true, :post_id => 666, :post_type => 'comment').should be_true
    end
  end
end
