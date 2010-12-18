#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe CommentsController do
  render_views

  let!(:user1)   { make_user }
  let!(:aspect1) { user1.aspects.create(:name => "AWESOME!!") }

  let!(:user2)   { make_user }
  let!(:aspect2) { user2.aspects.create(:name => "WIN!!") }

  before do
    sign_in :user, user1
  end

  describe '#create' do
    let(:comment_hash) {
      {:text    =>"facebook, is that you?",
       :post_id =>"#{@post.id}"}
    }
    context "on my own post" do
      before do
        @post = user1.post :status_message, :message => 'GIANTS', :to => aspect1.id
      end
      it 'responds to format js' do
        post :create, comment_hash.merge(:format => 'js')
        response.code.should == '201'
        response.body.should match comment_hash[:text]
      end
    end

    context "on a post from a contact" do
      before do
        connect_users(user1, aspect1, user2, aspect2)
        @post = user2.post :status_message, :message => 'GIANTS', :to => aspect2.id
      end
      it 'comments' do
        post :create, comment_hash
        response.code.should == '201'
      end
      it "doesn't overwrite person_id" do
        new_user = make_user
        comment_hash[:person_id] = new_user.person.id.to_s
        post :create, comment_hash
        Comment.find_by_text(comment_hash[:text]).person_id.should == user1.person.id
      end
      it "doesn't overwrite id" do
        old_comment = user1.comment("hello", :on => @post)
        comment_hash[:id] = old_comment.id
        post :create, comment_hash
        old_comment.reload.text.should == 'hello'
      end
    end
    context 'on a post from a stranger' do
      before do
        @post = user2.post :status_message, :message => 'GIANTS', :to => aspect2.id
      end
      it 'posts no comment' do
        user1.should_not_receive(:comment)
        post :create, comment_hash
        response.code.should == '406'
      end
    end
  end
end
