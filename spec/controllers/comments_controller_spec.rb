#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe CommentsController do
  render_views

  before do
    @aspect1 = alice.aspects.first
    @aspect2 = bob.aspects.first

    @controller.stub(:current_user).and_return(alice)
    sign_in :user, alice
  end

  describe '#create' do
    let(:comment_hash) {
      {:text    =>"facebook, is that you?",
       :post_id =>"#{@post.id}"}
    }
    context "on my own post" do
      before do
        @post = alice.post :status_message, :text => 'GIANTS', :to => @aspect1.id
      end
      it 'responds to format js' do
        post :create, comment_hash.merge(:format => 'js')
        response.code.should == '201'
        response.body.should match comment_hash[:text]
      end
    end

    context "on a post from a contact" do
      before do
        @post = bob.post :status_message, :text => 'GIANTS', :to => @aspect2.id
      end
      it 'comments' do
        post :create, comment_hash
        response.code.should == '201'
      end
      it "doesn't overwrite author_id" do
        new_user = Factory.create(:user)
        comment_hash[:author_id] = new_user.person.id.to_s
        post :create, comment_hash
        Comment.find_by_text(comment_hash[:text]).author_id.should == alice.person.id
      end
      it "doesn't overwrite id" do
        old_comment = alice.comment("hello", :on => @post)
        comment_hash[:id] = old_comment.id
        post :create, comment_hash
        old_comment.reload.text.should == 'hello'
      end
    end
    context 'on a post from a stranger' do
      before do
        @post = eve.post :status_message, :text => 'GIANTS', :to => eve.aspects.first.id
      end
      it 'posts no comment' do
        alice.should_not_receive(:comment)
        post :create, comment_hash
        response.code.should == '422'
      end
    end
  end

  describe '#destroy' do
    context 'your post' do
      before do
        @message = alice.post(:status_message, :text => "hey", :to => @aspect1.id)
        @comment = alice.comment("hey", :on => @message)
        @comment2 = bob.comment("hey", :on => @message)
        @comment3 = eve.comment("hey", :on => @message)
      end
      it 'lets the user delete his comment' do
        alice.should_receive(:retract).with(@comment)
        delete :destroy, :format => "js",  :id => @comment.id
        response.status.should == 204
      end

      it "lets the user destroy other people's comments" do
        alice.should_receive(:retract).with(@comment2)
        delete :destroy, :format => "js",  :id => @comment2.id
        response.status.should == 204
      end
    end

    context "another user's post" do
      before do
        @message = bob.post(:status_message, :text => "hey", :to => bob.aspects.first.id)
        @comment = alice.comment("hey", :on => @message)
        @comment2 = bob.comment("hey", :on => @message)
        @comment3 = eve.comment("hey", :on => @message)
      end

      it 'let the user delete his comment' do
        alice.should_receive(:retract).with(@comment)
        delete :destroy, :format => "js",  :id => @comment.id
        response.status.should == 204
      end

      it 'does not let the user destroy comments he does not own' do
        alice.should_not_receive(:retract).with(@comment2)
        delete :destroy, :format => "js",  :id => @comment3.id
        response.status.should == 403
      end
    end
  end
end
