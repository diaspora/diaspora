#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe LikesController do
  before do
    @user1 = alice
    @user2 = bob

    @aspect1 = @user1.aspects.first
    @aspect2 = @user2.aspects.first

    @controller.stub(:current_user).and_return(alice)
    sign_in :user, @user1
  end

  describe '#create' do
    let(:like_hash) {
      {:positive => 1,
       :post_id => "#{@post.id}"}
    }
    let(:dislike_hash) {
      {:positive => 0,
       :post_id => "#{@post.id}"}
    }

    context "on my own post" do
      before do
        @post = @user1.post :status_message, :text => "AWESOME", :to => @aspect1.id
      end

      it 'responds to format js' do
        post :create, like_hash.merge(:format => 'js')
        response.code.should == '201'
      end
    end

    context "on a post from a contact" do
      before do
        @post = @user2.post :status_message, :text => "AWESOME", :to => @aspect2.id
      end

      it 'likes' do
        post :create, like_hash
        response.code.should == '201'
      end

      it 'dislikes' do
        post :create, dislike_hash
        response.code.should == '201'
      end

      it "doesn't post multiple times" do
        @user1.like(1, :on => @post)
        post :create, dislike_hash
        response.code.should == '422'
      end
    end

    context "on a post from a stranger" do
      before do
        @post = eve.post :status_message, :text => "AWESOME", :to => eve.aspects.first.id
      end

      it "doesn't post" do
        @user1.should_not_receive(:like)
        post :create, like_hash
        response.code.should == '422'
      end
    end
  end

  describe '#destroy' do
    context 'your like' do
      before do
        @message = bob.post(:status_message, :text => "hey", :to => @aspect1.id)
        @like = alice.build_like(:positive => true, :on => @message)
        @like.save
      end

      it 'lets a user destroy their like' do
        expect {
          delete :destroy, :format => "js", :post_id => @like.post_id, :id => @like.id
        }.should change(Like, :count).by(-1)
      end

      it 'does not let a user destroy other likes' do
        like2 = eve.build_like(:positive => true, :on => @message)
        like2.save

        expect {
          delete :destroy, :format => "js", :post_id => like2.post_id, :id => like2.id
        }.should_not change(Like, :count)
      end
    end
  end
end
