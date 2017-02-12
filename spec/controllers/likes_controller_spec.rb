  #   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe LikesController, :type => :controller do
  before do
    @alices_aspect = alice.aspects.where(:name => "generic").first
    @bobs_aspect = bob.aspects.where(:name => "generic").first

    sign_in(alice, scope: :user)
  end

  [Comment, Post].each do |class_const|
    context class_const.to_s do
        let(:id_field){
          "#{class_const.to_s.underscore}_id"
        }

      describe '#create' do
        let(:like_hash) {
          {:positive => 1,
           id_field => "#{@target.id}"}
        }
        let(:dislike_hash) {
          {:positive => 0,
           id_field => "#{@target.id}"}
        }

        context "on my own post" do
          it 'succeeds' do
            @target = alice.post :status_message, :text => "AWESOME", :to => @alices_aspect.id
            @target = alice.comment!(@target, "hey") if class_const == Comment
            post :create, like_hash.merge(:format => :json)
            expect(response.code).to eq('201')
          end
        end

        context "on a post from a contact" do
          before do
            @target = bob.post(:status_message, :text => "AWESOME", :to => @bobs_aspect.id)
            @target = bob.comment!(@target, "hey") if class_const == Comment
          end

          it 'likes' do
            post :create, like_hash
            expect(response.code).to eq('201')
          end

          it 'dislikes' do
            post :create, dislike_hash
            expect(response.code).to eq('201')
          end

          it "doesn't post multiple times" do
            alice.like!(@target)
            post :create, dislike_hash
            expect(response.code).to eq('422')
          end
        end

        context "on a post from a stranger" do
          before do
            @target = eve.post :status_message, :text => "AWESOME", :to => eve.aspects.first.id
            @target = eve.comment!(@target, "hey") if class_const == Comment
          end

          it "doesn't post" do
            expect(alice).not_to receive(:like!)
            post :create, like_hash
            expect(response.code).to eq('422')
          end
        end

        context "when an the exception is raised" do
          before do
            @target = alice.post :status_message, :text => "AWESOME", :to => @alices_aspect.id
            @target = alice.comment!(@target, "hey") if class_const == Comment
          end

          it "should be catched when it means that the target is not found" do
            params = like_hash.merge(format: :json, id_field => -1)
            post :create, params
            expect(response.code).to eq('422')
          end

          it "should not be catched when it is unexpected" do
            @target = alice.post :status_message, :text => "AWESOME", :to => @alices_aspect.id
            @target = alice.comment!(@target, "hey") if class_const == Comment
            allow(alice).to receive(:like!).and_raise("something")
            allow(@controller).to receive(:current_user).and_return(alice)
            expect { post :create, like_hash.merge(:format => :json) }.to raise_error("something")
          end
        end
      end

      describe '#index' do
        before do
          @message = alice.post(:status_message, :text => "hey", :to => @alices_aspect.id)
          @message = alice.comment!(@message, "hey") if class_const == Comment
        end

        it 'returns a 404 for a post not visible to the user' do
          sign_in eve
          expect{get :index, id_field => @message.id}.to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'returns an array of likes for a post' do
          like = bob.like!(@message)
          get :index, id_field => @message.id
          expect(assigns[:likes].map(&:id)).to eq(@message.likes.map(&:id))
        end

        it 'returns an empty array for a post with no likes' do
          get :index, id_field => @message.id
          expect(assigns[:likes]).to eq([])
        end
      end

      describe '#destroy' do
        before do
          @message = bob.post(:status_message, :text => "hey", :to => @alices_aspect.id)
          @message = bob.comment!(@message, "hey") if class_const == Comment
          @like = alice.like!(@message)
        end

        it 'lets a user destroy their like' do
          current_user = controller.send(:current_user)
          expect(current_user).to receive(:retract).with(@like)

          delete :destroy, :format => :json, id_field => @like.target_id, :id => @like.id
          expect(response.status).to eq(204)
        end

        it 'does not let a user destroy other likes' do
          like2 = eve.like!(@message)
          like_count = Like.count

          delete :destroy, :format => :json, id_field => like2.target_id, :id => like2.id
          expect(response.status).to eq(404)
          expect(response.body).to eq(I18n.t("likes.destroy.error"))
          expect(Like.count).to eq(like_count)
        end
      end
    end
  end
end
