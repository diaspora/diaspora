# frozen_string_literal: true

describe LikeService do
  let(:post) { alice.post(:status_message, text: "hello", to: alice.aspects.first) }
  let(:alice_comment) { CommentService.new(alice).create(post.id, "This is a wonderful post") }
  let(:bobs_comment) { CommentService.new(bob).create(post.id, "My post was better than yours") }

  describe "#create_for_post" do
    it "creates a like on my own post" do
      expect {
        LikeService.new(alice).create_for_post(post.id)
      }.not_to raise_error
    end

    it "creates a like on a post of a contact" do
      expect {
        LikeService.new(bob).create_for_post(post.id)
      }.not_to raise_error
    end

    it "attaches the like to the post" do
      like = LikeService.new(alice).create_for_post(post.id)
      expect(post.likes.first.id).to eq(like.id)
    end

    it "fails if the post does not exist" do
      expect {
        LikeService.new(bob).create_for_post("unknown id")
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "fails if the user can't see the post" do
      expect {
        LikeService.new(eve).create_for_post(post.id)
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "fails if the user already liked the post" do
      LikeService.new(alice).create_for_post(post.id)
      expect {
        LikeService.new(alice).create_for_post(post.id)
      }.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe "#create_for_comment" do
    it "creates a like on a posts comment" do
      expect {
        LikeService.new(alice).create_for_comment(alice_comment.id)
      }.not_to raise_error
    end

    it "creates a like on someone else comment" do
      expect {
        LikeService.new(alice).create_for_comment(bobs_comment.id)
      }.not_to raise_error
    end

    it "attaches the like to the comment" do
      like = LikeService.new(alice).create_for_comment(bobs_comment.id)
      expect(bobs_comment.likes.first.id).to eq(like.id)
    end

    it "fails if comment does not exist" do
      expect {
        LikeService.new(alice).create_for_comment("unknown_id")
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "fails if user cant see post and its comments" do
      expect {
        LikeService.new(eve).create_for_comment(bobs_comment.id)
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "fails if user already liked the comment" do
      LikeService.new(alice).create_for_comment(bobs_comment.id)
      expect {
        LikeService.new(alice).create_for_comment(bobs_comment.id)
      }.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe "#destroy" do
    context "for post like" do
      let(:like) { LikeService.new(bob).create_for_post(post.id) }

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

    context "for comment like" do
      let(:like) { LikeService.new(bob).create_for_comment(alice_comment.id) }

      it "let the user destroy its own comment like" do
        result = LikeService.new(bob).destroy(like.id)
        expect(result).to be_truthy
      end

      it "doesn't let the parent author destroy other comment likes" do
        result = LikeService.new(alice).destroy(like.id)
        expect(result).to be_falsey
      end

      it "fails if the like doesn't exist" do
        expect {
          LikeService.new(alice).destroy("unknown id")
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "#find_for_post" do
    context "with user" do
      it "returns likes for a public post" do
        post = alice.post(:status_message, text: "hello", public: true)
        like = LikeService.new(alice).create_for_post(post.id)
        expect(LikeService.new(eve).find_for_post(post.id)).to include(like)
      end

      it "returns likes for a visible private post" do
        like = LikeService.new(alice).create_for_post(post.id)
        expect(LikeService.new(bob).find_for_post(post.id)).to include(like)
      end

      it "doesn't return likes for a private post the user can not see" do
        LikeService.new(alice).create_for_post(post.id)
        expect {
          LikeService.new(eve).find_for_post(post.id)
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it "returns the user's like first" do
        post = alice.post(:status_message, text: "hello", public: true)
        [alice, bob, eve].map {|user| LikeService.new(user).create_for_post(post.id) }

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
        like = LikeService.new(alice).create_for_post(post.id)
        expect(LikeService.new.find_for_post(post.id)).to include(like)
      end

      it "doesn't return likes a for private post" do
        LikeService.new(alice).create_for_post(post.id)
        expect {
          LikeService.new.find_for_post(post.id)
        }.to raise_error Diaspora::NonPublic
      end
    end

    it "returns all likes of a post" do
      post = alice.post(:status_message, text: "hello", public: true)
      likes = [alice, bob, eve].map {|user| LikeService.new(user).create_for_post(post.id) }

      expect(LikeService.new.find_for_post(post.id)).to match_array(likes)
    end
  end

  describe "#find_for_comment" do
    context "with user" do
      it "returns likes for a public post comment" do
        post = alice.post(:status_message, text: "hello", public: true)
        comment = CommentService.new(bob).create(post.id, "Hello comment")
        like = LikeService.new(alice).create_for_comment(comment.id)
        expect(LikeService.new(eve).find_for_comment(comment.id)).to include(like)
      end

      it "returns likes for visible private post comments" do
        comment = CommentService.new(bob).create(post.id, "Hello comment")
        like = LikeService.new(alice).create_for_comment(comment.id)
        expect(LikeService.new(bob).find_for_comment(comment.id)).to include(like)
      end

      it "doesn't return likes for a posts comment the user can not see" do
        expect {
          LikeService.new(eve).find_for_comment(alice_comment.id)
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it "returns the user's like first" do
        post = alice.post(:status_message, text: "hello", public: true)
        comment = CommentService.new(alice).create(post.id, "I like my own post")

        [alice, bob, eve].map {|user| LikeService.new(user).create_for_comment(comment.id) }
        [alice, bob, eve].each do |user|
          expect(
            LikeService.new(user).find_for_comment(comment.id).first.author.id
          ).to be user.person.id
        end
      end
    end

    context "without user" do
      it "returns likes for a comment on a public post" do
        post = alice.post(:status_message, text: "hello", public: true)
        comment = CommentService.new(bob).create(post.id, "I like my own post")
        like = LikeService.new(alice).create_for_comment(comment.id)
        expect(
          LikeService.new.find_for_comment(comment.id)
        ).to include(like)
      end

      it "doesn't return likes for a private post comment" do
        LikeService.new(alice).create_for_comment(alice_comment.id)
        expect {
          LikeService.new.find_for_comment(alice_comment.id)
        }.to raise_error Diaspora::NonPublic
      end
    end
  end

  describe "#unlike_post" do
    before do
      LikeService.new(alice).create_for_post(post.id)
    end

    it "removes the like to the post" do
      LikeService.new(alice).unlike_post(post.id)
      expect(post.likes.length).to eq(0)
    end
  end

  describe "#unlike_comment" do
    it "removes the like for a comment" do
      comment = CommentService.new(alice).create(post.id, "I like my own post")
      LikeService.new(alice).create_for_comment(comment.id)
      expect(comment.likes.length).to eq(1)

      LikeService.new(alice).unlike_comment(comment.id)
      comment = CommentService.new(alice).find!(comment.id)
      expect(comment.likes.length).to eq(0)
    end
  end
end
