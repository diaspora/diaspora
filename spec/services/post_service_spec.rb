describe PostService do
  let(:post) { alice.post(:status_message, text: "ohai", to: alice.aspects.first) }
  let(:public) { alice.post(:status_message, text: "hey", public: true) }

  describe "#find" do
    context "with user" do
      it "returns the post, if it is the users post" do
        expect(PostService.new(alice).find(post.id)).to eq(post)
      end

      it "returns the post, if the user can see the it" do
        expect(PostService.new(bob).find(post.id)).to eq(post)
      end

      it "returns the post, if it is public" do
        expect(PostService.new(eve).find(public.id)).to eq(public)
      end

      it "does not return the post, if the post cannot be found" do
        expect(PostService.new(alice).find("unknown")).to be_nil
      end

      it "does not return the post, if user cannot see the post" do
        expect(PostService.new(eve).find(post.id)).to be_nil
      end
    end

    context "without user" do
      it "returns the post, if it is public" do
        expect(PostService.new.find(public.id)).to eq(public)
      end

      it "does not return the post, if the post is private" do
        expect(PostService.new.find(post.id)).to be_nil
      end

      it "does not return the post, if the post cannot be found" do
        expect(PostService.new.find("unknown")).to be_nil
      end
    end
  end

  describe "#find!" do
    context "with user" do
      it "returns the post, if it is the users post" do
        expect(PostService.new(alice).find!(post.id)).to eq(post)
      end

      it "works with guid" do
        expect(PostService.new(alice).find!(post.guid)).to eq(post)
      end

      it "returns the post, if the user can see the it" do
        expect(PostService.new(bob).find!(post.id)).to eq(post)
      end

      it "returns the post, if it is public" do
        expect(PostService.new(eve).find!(public.id)).to eq(public)
      end

      it "RecordNotFound if the post cannot be found" do
        expect {
          PostService.new(alice).find!("unknown")
        }.to raise_error ActiveRecord::RecordNotFound, "could not find a post with id unknown for user #{alice.id}"
      end

      it "RecordNotFound if user cannot see the post" do
        expect {
          PostService.new(eve).find!(post.id)
        }.to raise_error ActiveRecord::RecordNotFound, "could not find a post with id #{post.id} for user #{eve.id}"
      end
    end

    context "without user" do
      it "returns the post, if it is public" do
        expect(PostService.new.find!(public.id)).to eq(public)
      end

      it "works with guid" do
        expect(PostService.new.find!(public.guid)).to eq(public)
      end

      it "NonPublic if the post is private" do
        expect {
          PostService.new.find!(post.id)
        }.to raise_error Diaspora::NonPublic
      end

      it "RecordNotFound if the post cannot be found" do
        expect {
          PostService.new.find!("unknown")
        }.to raise_error ActiveRecord::RecordNotFound, "could not find a post with id unknown"
      end
    end

    context "id/guid switch" do
      let(:public) { alice.post(:status_message, text: "ohai", public: true) }

      it "assumes ids less than 16 chars are ids and not guids" do
        post = Post.where(id: public.id)
        expect(Post).to receive(:where).with(hash_including(id: "123456789012345")).and_return(post).at_least(:once)
        PostService.new(alice).find!("123456789012345")
      end

      it "assumes ids more than (or equal to) 16 chars are actually guids" do
        post = Post.where(guid: public.guid)
        expect(Post).to receive(:where).with(hash_including(guid: "1234567890123456")).and_return(post).at_least(:once)
        PostService.new(alice).find!("1234567890123456")
      end
    end
  end

  describe "#mark_user_notifications" do
    it "marks a corresponding notifications as read" do
      FactoryGirl.create(:notification, recipient: alice, target: post, unread: true)
      FactoryGirl.create(:notification, recipient: alice, target: post, unread: true)

      expect {
        PostService.new(alice).mark_user_notifications(post.id)
      }.to change(Notification.where(unread: true), :count).by(-2)
    end

    it "marks a corresponding mention notification as read" do
      status_text = "this is a text mentioning @{Mention User ; #{alice.diaspora_handle}} ... have fun testing!"
      mention_post = bob.post(:status_message, text: status_text, public: true)

      expect {
        PostService.new(alice).mark_user_notifications(mention_post.id)
      }.to change(Notification.where(unread: true), :count).by(-1)
    end

    it "does not change the update_at date/time for post notifications" do
      notification = Timecop.travel(1.minute.ago) do
        FactoryGirl.create(:notification, recipient: alice, target: post, unread: true)
      end

      expect {
        PostService.new(alice).mark_user_notifications(post.id)
      }.not_to change { Notification.where(id: notification.id).pluck(:updated_at) }
    end

    it "does not change the update_at date/time for mention notifications" do
      status_text = "this is a text mentioning @{Mention User ; #{alice.diaspora_handle}} ... have fun testing!"
      mention_post = Timecop.travel(1.minute.ago) do
        bob.post(:status_message, text: status_text, public: true)
      end
      mention = mention_post.mentions.where(person_id: alice.person.id).first

      expect {
        PostService.new(alice).mark_user_notifications(post.id)
      }.not_to change { Notification.where(target_type: "Mention", target_id: mention.id).pluck(:updated_at) }
    end

    it "does nothing without a user" do
      expect_any_instance_of(PostService).not_to receive(:mark_comment_reshare_like_notifications_read).with(post.id)
      expect_any_instance_of(PostService).not_to receive(:mark_mention_notifications_read).with(post.id)
      PostService.new.mark_user_notifications(post.id)
    end
  end

  describe "#destroy" do
    it "let a user delete his message" do
      PostService.new(alice).destroy(post.id)
      expect(StatusMessage.find_by_id(post.id)).to be_nil
    end

    it "sends a retraction on delete" do
      expect(alice).to receive(:retract).with(post)
      PostService.new(alice).destroy(post.id)
    end

    it "will not let you destroy posts visible to you but that you do not own" do
      expect {
        PostService.new(bob).destroy(post.id)
      }.to raise_error Diaspora::NotMine
      expect(StatusMessage.find_by_id(post.id)).not_to be_nil
    end

    it "will not let you destroy posts that are not visible to you" do
      expect {
        PostService.new(eve).destroy(post.id)
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect(StatusMessage.find_by_id(post.id)).not_to be_nil
    end
  end
end
