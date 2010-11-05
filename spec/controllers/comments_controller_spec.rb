#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe CommentsController do
  render_views

  let!(:user) { make_user }
  let!(:aspect) { user.aspects.create(:name => "AWESOME!!") }

  let!(:user2) { make_user }
  let!(:aspect2) { user2.aspects.create(:name => "WIN!!") }

  before do
    sign_in :user, user
  end

  describe '#create' do
    let(:comment_hash) {
      {:comment =>{
        :text =>"facebook, is that you?", 
        :post_id     =>"#{@post.id}"}}
    }

    context "on a post from a friend" do
      before do
        friend_users(user, aspect, user2, aspect2)
        @post = user2.post :status_message, :message => 'GIANTS', :to => aspect2.id
      end
      it 'comments' do
        post :create, comment_hash
        response.code.should == '201'
      end
      it "doesn't overwrite person_id" do
        new_user = make_user
        comment_hash[:comment][:person_id] = new_user.person.id.to_s
        post :create, comment_hash
        Comment.find_by_text(comment_hash[:comment][:text]).person_id.should == user.person.id
      end
      it "doesn't overwrite id" do
        old_comment = user.comment("hello", :on => @post)
        comment_hash[:comment][:id] = old_comment.id
        post :create, comment_hash
        old_comment.reload.text.should == 'hello'
      end
    end
    context 'on a post from a stranger' do
      before do
        @post = user2.post :status_message, :message => 'GIANTS', :to => aspect2.id
      end
      it 'posts no comment' do
        user.should_receive(:comment).exactly(0).times
        post :create, comment_hash
        response.code.should == '401'
      end
    end
  end
end
