#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe CommentsController, :type => :controller do
  before do
    allow(@controller).to receive(:current_user).and_return(alice)
    sign_in :user, alice
  end

  describe '#create' do
    let(:comment_hash) {
      {:text    =>"facebook, is that you?",
       :post_id =>"#{@post.id}"}
    }

    context "on my own post" do
      before do
        aspect_to_post = alice.aspects.where(:name => "generic").first
        @post = alice.post :status_message, :text => 'GIANTS', :to => aspect_to_post
      end

      it 'responds to format json' do
        post :create, comment_hash.merge(:format => 'json')
        expect(response.code).to eq('201')
        expect(response.body).to match comment_hash[:text]
      end

      it 'responds to format mobile' do
        post :create, comment_hash.merge(:format => 'mobile')
        expect(response).to be_success
      end
    end

    context "on a post from a contact" do
      before do
        aspect_to_post = bob.aspects.where(:name => "generic").first
        @post = bob.post :status_message, :text => 'GIANTS', :to => aspect_to_post
      end

      it 'comments' do
        post :create, comment_hash
        expect(response.code).to eq('201')
      end

      it "doesn't overwrite author_id" do
        new_user = FactoryGirl.create(:user)
        comment_hash[:author_id] = new_user.person.id.to_s
        post :create, comment_hash
        expect(Comment.find_by_text(comment_hash[:text]).author_id).to eq(alice.person.id)
      end

      it "doesn't overwrite id" do
        old_comment = alice.comment!(@post, "hello")
        comment_hash[:id] = old_comment.id
        post :create, comment_hash
        expect(old_comment.reload.text).to eq('hello')
      end
    end

    it 'posts no comment on a post from a stranger' do
      aspect_to_post = eve.aspects.where(:name => "generic").first
      @post = eve.post :status_message, :text => 'GIANTS', :to => aspect_to_post

      expect(alice).not_to receive(:comment)
      post :create, comment_hash
      expect(response.code).to eq('422')
    end
  end

  describe '#destroy' do
    before do
      aspect_to_post = bob.aspects.where(:name => "generic").first
      @message = bob.post(:status_message, :text => "hey", :to => aspect_to_post)
    end

    context 'your post' do
      before do
        allow(@controller).to receive(:current_user).and_return(bob)
        sign_in :user, bob
      end

      it 'lets the user delete his comment' do
        comment = bob.comment!(@message, "hey")

        expect(bob).to receive(:retract).with(comment)
        delete :destroy, :format => "js", :post_id => 1, :id => comment.id
        expect(response.status).to eq(204)
      end

      it "lets the user destroy other people's comments" do
        comment = alice.comment!(@message, "hey")

        expect(bob).to receive(:retract).with(comment)
        delete :destroy, :format => "js", :post_id => 1, :id => comment.id
        expect(response.status).to eq(204)
      end
    end

    context "another user's post" do
      it 'let the user delete his comment' do
        comment = alice.comment!(@message, "hey")

        expect(alice).to receive(:retract).with(comment)
        delete :destroy, :format => "js", :post_id => 1,  :id => comment.id
        expect(response.status).to eq(204)
      end

      it 'does not let the user destroy comments he does not own' do
        comment1 = bob.comment!(@message, "hey")
        comment2 = eve.comment!(@message, "hey")

        expect(alice).not_to receive(:retract).with(comment1)
        delete :destroy, :format => "js", :post_id => 1,  :id => comment2.id
        expect(response.status).to eq(403)
      end
    end

    it 'renders nothing and 404 on a nonexistent comment' do
      delete :destroy, :post_id => 1, :id => 343415
      expect(response.status).to eq(404)
      expect(response.body.strip).to be_empty
    end
  end

  describe '#index' do
    before do
      aspect_to_post = bob.aspects.where(:name => "generic").first
      @message = bob.post(:status_message, :text => "hey", :to => aspect_to_post.id)
    end

    it 'works for mobile' do
      get :index, :post_id => @message.id, :format => 'mobile'
      expect(response).to be_success
    end

    it 'returns all the comments for a post' do
      comments = [alice, bob, eve].map{ |u| u.comment!(@message, "hey") }

      get :index, :post_id => @message.id, :format => :json
      expect(assigns[:comments].map(&:id)).to match_array(comments.map(&:id))
    end

    it 'returns a 404 on a nonexistent post' do
      get :index, :post_id => 235236, :format => :json
      expect(response.status).to eq(404)
    end

    it 'returns a 404 on a post that is not visible to the signed in user' do
      aspect_to_post = eve.aspects.where(:name => "generic").first
      message = eve.post(:status_message, :text => "hey", :to => aspect_to_post.id)
      bob.comment!(@message, "hey")
      get :index, :post_id => message.id, :format => :json
      expect(response.status).to eq(404)
    end
  end
end
