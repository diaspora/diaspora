# frozen_string_literal: true

describe LikeService do
  let(:post) { alice.post(:status_message, text: "hello", to: alice.aspects.first) }

  describe "#create" do
    it "creates a like on my own post" do
      expect {
        LikeService.new(alice).create(post.id)
      }.not_to raise_error
    end

    it "creates a like on a post of a contact" do
      expect {
        LikeService.new(bob).create(post.id)
      }.not_to raise_error
    end

    it "attaches the like to the post" do
      like = LikeService.new(alice).create(post.id)
      expect(post.likes.first.id).to eq(like.id)
    end

    it "fails if the post does not exist" do
      expect {
        LikeService.new(bob).create("unknown id")
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "fails if the user can't see the post" do
      expect {
        LikeService.new(eve).create(post.id)
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "fails if the user already liked the post" do
      LikeService.new(alice).create(post.id)
      expect {
        LikeService.new(alice).create(post.id)
      }.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe "#destroy" do
    let(:like) { LikeService.new(bob).create(post.id) }

    it "lets the user destroy their own like" do
      result = LikeService.new(bob).destroy(like.id)
      expect(result).to be_truthy
    end

    it "doesn't let the parent author destroy others likes" do
      result = LikeService.new(alice).destroy(like.id)
      expect(result).to be_falsey
    end

    it "doesn't let someone destroy others likes" do
      result = LikeService.new(eve).destroy(like.id)
      expect(result).to be_falsey
    end

    it "fails if the like doesn't exist" do
      expect {
        LikeService.new(bob).destroy("unknown id")
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "#find_for_post" do
    context "with user" do
      it "returns likes for a public post" do
        post = alice.post(:status_message, text: "hello", public: true)
        like = LikeService.new(alice).create(post.id)
        expect(LikeService.new(eve).find_for_post(post.id)).to include(like)
      end

      it "returns likes for a visible private post" do
        like = LikeService.new(alice).create(post.id)
        expect(LikeService.new(bob).find_for_post(post.id)).to include(like)
      end

      it "doesn't return likes for a private post the user can not see" do
        LikeService.new(alice).create(post.id)
        expect {
          LikeService.new(eve).find_for_post(post.id)
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it "returns the user's like first" do
        post = alice.post(:status_message, text: "hello", public: true)
        [alice, bob, eve].map {|user| LikeService.new(user).create(post.id) }

        [alice, bob, eve].each do |user|
          expect(
            LikeService.new(user).find_for_post(post.id).first.author.id
          ).to be user.person.id
        end
      end
    end

    context "without user" do
      it "returns likes for a public post" do
        post = alice.post(:status_message, text: "hello", public: true)
        like = LikeService.new(alice).create(post.id)
        expect(LikeService.new.find_for_post(post.id)).to include(like)
      end

      it "doesn't return likes a for private post" do
        LikeService.new(alice).create(post.id)
        expect {
          LikeService.new.find_for_post(post.id)
        }.to raise_error Diaspora::NonPublic
      end
    end

    it "returns all likes of a post" do
      post = alice.post(:status_message, text: "hello", public: true)
      likes = [alice, bob, eve].map {|user| LikeService.new(user).create(post.id) }

      expect(LikeService.new.find_for_post(post.id)).to match_array(likes)
    end
  end

  describe "#unlike_post" do
    before do
      LikeService.new(alice).create(post.id)
    end

    it "removes the like to the post" do
      LikeService.new(alice).unlike_post(post.id)
      expect(post.likes.length).to eq(0)
    end
  end
end
