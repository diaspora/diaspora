require "spec_helper"

describe PostService do
  before do
    aspect = alice.aspects.first
    @message = alice.build_post :status_message, text: "ohai", to: aspect.id
    @message.save!

    alice.add_to_streams(@message, [aspect])
    alice.dispatch_post @message, to: aspect.id
  end

  describe "#assign_post" do
    context "when the post is private" do
      it "RecordNotFound if the post cannot be found" do
        expect { PostService.new(id: 1_234_567, user: alice) }.to raise_error(ActiveRecord::RecordNotFound)
      end
      it "NonPublic if there is no user" do
        expect { PostService.new(id: @message.id) }.to raise_error(Diaspora::NonPublic)
      end
      it "RecordNotFound if user cannot see post" do
        expect { PostService.new(id: @message.id, user: eve) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the post is public" do
      it "RecordNotFound if the post cannot be found" do
        expect { PostService.new(id: 1_234_567) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    # We want to be using guids from now on for this post route, but do not want to break
    # pre-exisiting permalinks.  We can assume a guid is 8 characters long as we have
    # guids set to hex(8) since we started using them.
    context "id/guid switch" do
      before do
        @status = alice.post(:status_message, text: "hello", public: true, to: "all")
      end

      it "assumes guids less than 8 chars are ids and not guids" do
        post = Post.where(id: @status.id.to_s)
        expect(Post).to receive(:where).with(hash_including(id: @status.id)).and_return(post).at_least(:once)
        PostService.new(id: @status.id, user: alice)
      end

      it "assumes guids more than (or equal to) 8 chars are actually guids" do
        post = Post.where(guid: @status.guid)
        expect(Post).to receive(:where).with(hash_including(guid: @status.guid)).and_return(post).at_least(:once)
        PostService.new(id: @status.guid, user: alice)
      end
    end
  end

  describe "#mark_user_notifications" do
    it "marks a corresponding notifications as read" do
      FactoryGirl.create(:notification, recipient: alice, target: @message, unread: true)
      FactoryGirl.create(:notification, recipient: alice, target: @message, unread: true)
      post_service = PostService.new(id: @message.id, user: alice)
      expect { post_service.mark_user_notifications }.to change(Notification.where(unread: true), :count).by(-2)
    end

    it "marks a corresponding mention notification as read" do
      status_text = "this is a text mentioning @{Mention User ; #{alice.diaspora_handle}} ... have fun testing!"
      status_msg =
        bob.post(:status_message, text: status_text, public: true, to: "all")
      mention = status_msg.mentions.where(person_id: alice.person.id).first
      FactoryGirl.create(:notification, recipient: alice, target_type: "Mention", target_id: mention.id, unread: true)
      post_service = PostService.new(id: status_msg.id, user: alice)
      expect { post_service.mark_user_notifications }.to change(Notification.where(unread: true), :count).by(-1)
    end
  end

  describe "#present_json" do
    it "works for a private post" do
      post_service = PostService.new(id: @message.id, user: alice)
      expect(post_service.present_json.to_json).to match(/\"text\"\:\"ohai\"/)
    end

    it "works for a public post " do
      status = alice.post(:status_message, text: "hello", public: true, to: "all")
      post_service = PostService.new(id: status.id)
      expect(post_service.present_json.to_json).to match(/\"text\"\:\"hello\"/)
    end
  end

  describe "#present_oembed" do
    it "works for a private post" do
      post_service = PostService.new(id: @message.id, user: alice)
      expect(post_service.present_oembed.to_json).to match(/iframe/)
    end

    it "works for a public post" do
      status = alice.post(:status_message, text: "hello", public: true, to: "all")
      post_service = PostService.new(id: status.id)
      expect(post_service.present_oembed.to_json).to match(/iframe/)
    end
  end

  describe "#retract_post" do
    it "let a user delete his message" do
      message = alice.post(:status_message, text: "hey", to: alice.aspects.first.id)
      post_service = PostService.new(id: message.id, user: alice)
      post_service.retract_post
      expect(StatusMessage.find_by_id(message.id)).to be_nil
    end

    it "sends a retraction on delete" do
      message = alice.post(:status_message, text: "hey", to: alice.aspects.first.id)
      post_service = PostService.new(id: message.id, user: alice)
      expect(alice).to receive(:retract).with(message)
      post_service.retract_post
    end

    it "will not let you destroy posts visible to you but that you do not own" do
      message = bob.post(:status_message, text: "hey", to: bob.aspects.first.id)
      post_service = PostService.new(id: message.id, user: alice)
      expect { post_service.retract_post }.to raise_error(Diaspora::NotMine)
      expect(StatusMessage.exists?(message.id)).to be true
    end

    it "will not let you destroy posts that are not visible to you" do
      message = eve.post(:status_message, text: "hey", to: eve.aspects.first.id)
      expect { PostService.new(id: message.id, user: alice) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(StatusMessage.exists?(message.id)).to be true
    end
  end
end
