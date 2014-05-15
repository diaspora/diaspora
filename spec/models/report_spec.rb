#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Report do
  before do
    #:report => { :item_id => @message.id, :item_type => 'post', :text => 'offensive content' }
    @user = bob
    @bob_post = @user.post(:status_message, :text => "hello", :to => @user.aspects.first.id)
    @bob_comment = @user.comment!(@bob_post, "welcome")

    @valid_post_report = {
      :item_id => @bob_post.id,
      :item_type => 'post',
      :text => 'offensive content'
    }
    @valid_comment_report = {
      :item_id => @bob_comment.id,
      :item_type => 'comment',
      :text => 'offensive content'
    }
  end

  describe '#validation' do
    it 'validates that post ID is required' do
      @user.reports.build(:item_type => 'post', :text => 'blub').should_not be_valid
    end
    
    it 'validates that post type is required' do
      @user.reports.build(:item_id => 666, :text => 'blub').should_not be_valid
    end

    it 'validates that entry does not exist' do
      @user.reports.build(@valid_post_report).should be_valid
    end
    
    it 'validates that entry does exist' do
      @user.reports.create(@valid_post_report)
      @user.reports.build(@valid_post_report).should_not be_valid
    end
  end

  describe '#destroy_reported_item' do
    before(:each) do
      @post_report = @user.reports.create(@valid_post_report)
      @comment_report = @user.reports.create(@valid_comment_report)
    end

    describe '.post' do
      it 'should destroy it' do
        expect {
          @post_report.destroy_reported_item
        }.to change { Post.count }.by(-1)
      end

      it 'should be marked' do
        expect {
          @post_report.destroy_reported_item
        }.to change { Report.where(@valid_post_report).first.reviewed }.to(true).from(false)
      end
    end

    describe '.comment' do
      it 'should destroy it' do
        expect {
          @comment_report.destroy_reported_item
        }.to change { Comment.count }.by(-1)
      end

      it 'should be marked' do
        expect {
          @comment_report.destroy_reported_item
        }.to change { Report.where(@valid_comment_report).first.reviewed }.to(true).from(false)
      end
    end
  end
end
