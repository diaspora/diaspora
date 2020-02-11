# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe CommentsController, :type => :controller do
  before do
    sign_in alice, scope: :user
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
        post :create, params: comment_hash, format: :json
        expect(response.code).to eq('201')
        expect(response.body).to match comment_hash[:text]
      end

      it 'responds to format mobile' do
        post :create, params: comment_hash, format: :mobile
        expect(response).to be_successful
      end
    end

    context "on a post from a contact" do
      before do
        aspect_to_post = bob.aspects.where(:name => "generic").first
        @post = bob.post :status_message, :text => 'GIANTS', :to => aspect_to_post
      end

      it 'comments' do
        post :create, params: comment_hash
        expect(response.code).to eq('201')
      end

      it "doesn't overwrite author_id" do
        new_user = FactoryGirl.create(:user)
        comment_hash[:author_id] = new_user.person.id.to_s
        post :create, params: comment_hash
        expect(Comment.find_by_text(comment_hash[:text]).author_id).to eq(alice.person.id)
      end

      it "doesn't overwrite id" do
        old_comment = alice.comment!(@post, "hello")
        comment_hash[:id] = old_comment.id
        post :create, params: comment_hash
        expect(old_comment.reload.text).to eq('hello')
      end
    end

    it 'posts no comment on a post from a stranger' do
      aspect_to_post = eve.aspects.where(:name => "generic").first
      @post = eve.post :status_message, :text => 'GIANTS', :to => aspect_to_post

      allow(@controller).to receive(:current_user).and_return(alice)
      expect(alice).not_to receive(:comment)
      post :create, params: comment_hash
      expect(response.code).to eq("404")
      expect(response.body).to eq(I18n.t("comments.create.error"))
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
        sign_in bob, scope: :user
      end

      it "lets the user delete their comment" do
        comment = bob.comment!(@message, "hey")

        expect(bob).to receive(:retract).with(comment)
        delete :destroy, params: {post_id: 1, id: comment.id}, format: :js
        expect(response.status).to eq(204)
      end

      it "lets the user destroy other people's comments" do
        comment = alice.comment!(@message, "hey")

        expect(bob).to receive(:retract).with(comment)
        delete :destroy, params: {post_id: 1, id: comment.id}, format: :js
        expect(response.status).to eq(204)
      end
    end

    context "another user's post" do
      it "lets the user delete their comment" do
        comment = alice.comment!(@message, "hey")

        allow(@controller).to receive(:current_user).and_return(alice)
        expect(alice).to receive(:retract).with(comment)
        delete :destroy, params: {post_id: 1, id: comment.id}, format: :js
        expect(response.status).to eq(204)
      end

      it "does not let the user destroy comments they do not own" do
        comment1 = bob.comment!(@message, "hey")
        comment2 = eve.comment!(@message, "hey")

        allow(@controller).to receive(:current_user).and_return(alice)
        expect(alice).not_to receive(:retract).with(comment1)
        delete :destroy, params: {post_id: 1, id: comment2.id}, format: :js
        expect(response.status).to eq(403)
      end
    end

    it 'renders nothing and 404 on a nonexistent comment' do
      delete :destroy, params: {post_id: 1, id: 343_415}
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
      get :index, params: {post_id: @message.id}, format: :mobile
      expect(response).to be_successful
    end

    it 'returns all the comments for a post' do
      comments = [alice, bob, eve].map{ |u| u.comment!(@message, "hey") }

      get :index, params: {post_id: @message.id}, format: :json
      expect(JSON.parse(response.body).map {|comment| comment["id"] }).to match_array(comments.map(&:id))
    end

    it 'returns a 404 on a nonexistent post' do
      get :index, params: {post_id: 235_236}, format: :json
      expect(response.status).to eq(404)
    end

    it 'returns a 404 on a post that is not visible to the signed in user' do
      aspect_to_post = eve.aspects.where(:name => "generic").first
      message = eve.post(:status_message, :text => "hey", :to => aspect_to_post.id)
      bob.comment!(@message, "hey")
      get :index, params: {post_id: message.id}, format: :json
      expect(response.status).to eq(404)
    end

    it "returns a 401 for a private post when logged out" do
      bob.comment!(@message, "hey")
      sign_out :user
      get :index, params: {post_id: @message.id}, format: :json
      expect(response.status).to eq(401)
    end
  end
end
