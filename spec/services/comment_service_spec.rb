# frozen_string_literal: true

describe CommentService do
  let(:post) { alice.post(:status_message, text: "hello", to: alice.aspects.first) }

  describe "#create" do
    it "creates a comment on my own post" do
      comment = CommentService.new(alice).create(post.id, "hi")
      expect(comment.text).to eq("hi")
    end

    it "creates a comment on post of a contact" do
      comment = CommentService.new(bob).create(post.id, "hi")
      expect(comment.text).to eq("hi")
    end

    it "attaches the comment to the post" do
      comment = CommentService.new(alice).create(post.id, "hi")
      expect(post.comments.first.text).to eq("hi")
      expect(post.comments.first.id).to eq(comment.id)
    end

    it "fail if the post does not exist" do
      expect {
        CommentService.new(alice).create("unknown id", "hi")
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "fail if the user can not see the post" do
      expect {
        CommentService.new(eve).create(post.id, "hi")
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "#destroy" do
    let(:comment) { CommentService.new(bob).create(post.id, "hi") }

    it "lets the user destroy his own comment" do
      result = CommentService.new(bob).destroy(comment.id)
      expect(result).to be_truthy
    end

    it "lets the parent author destroy others comment" do
      result = CommentService.new(alice).destroy(comment.id)
      expect(result).to be_truthy
    end

    it "does not let someone destroy others comment" do
      result = CommentService.new(eve).destroy(comment.id)
      expect(result).to be_falsey
    end

    it "fails if the comment does not exist" do
      expect {
        CommentService.new(bob).destroy("unknown id")
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "#find_for_post" do
    context "with user" do
      it "returns comments for a public post" do
        post = alice.post(:status_message, text: "hello", public: true)
        comment = CommentService.new(alice).create(post.id, "hi")
        expect(CommentService.new(eve).find_for_post(post.id)).to include(comment)
      end

      it "returns comments for a visible private post" do
        comment = CommentService.new(alice).create(post.id, "hi")
        expect(CommentService.new(bob).find_for_post(post.id)).to include(comment)
      end

      it "does not return comments for private post the user can not see" do
        expect {
          CommentService.new(eve).find_for_post(post.id)
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context "without user" do
      it "returns comments for a public post" do
        post = alice.post(:status_message, text: "hello", public: true)
        comment = CommentService.new(alice).create(post.id, "hi")
        expect(CommentService.new.find_for_post(post.id)).to include(comment)
      end

      it "does not return comments for private post" do
        expect {
          CommentService.new.find_for_post(post.id)
        }.to raise_error Diaspora::NonPublic
      end
    end

    it "returns all comments of a post" do
      post = alice.post(:status_message, text: "hello", public: true)
      comments = [alice, bob, eve].map {|user| CommentService.new(user).create(post.id, "hi") }

      expect(CommentService.new.find_for_post(post.id)).to match_array(comments)
    end
  end
end
