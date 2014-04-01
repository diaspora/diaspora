#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Report do
  before do
    #:report => { :post_id => @message.id, :post_type => 'post', :text => 'offensive content' }
    @user = bob
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
      @user.reports.build(:post_type => 'post', :text => 'blub').should_not be_valid
    end
    
    it 'validates that post type is required' do
      @user.reports.build(:post_id => 666, :text => 'blub').should_not be_valid
    end

    it 'validates that entry does not exist' do
      @user.reports.build(@valid_post).should be_valid
    end
    
    it 'validates that entry does exist' do
      @user.reports.create(@valid_post)
      @user.reports.build(@valid_post).should_not be_valid
    end
  end

  describe '#destroy_reported_item' do
    before do
      @post = @user.reports.create(@valid_post)
      @comment = @user.reports.create(@valid_comment)
    end

    describe '.post' do
      it 'should destroy it' do
        @post.destroy_reported_item.should be_true
      end

      it 'should be marked' do
        expect {
          @post.destroy_reported_item
        }.to change{ Report.where(@valid_post).first.reviewed }.to(true).from(false)
      end
    end

    describe '.comment' do
      it 'should destroy it' do
        @comment.destroy_reported_item.should be_true
      end

      xit 'nothing' do
      end

      it 'should be marked' do
        expect {
          @comment.destroy_reported_item
        }.to change{ Report.where(@valid_comment).first.reviewed }.to(true).from(false)
      end
    end
  end
end
