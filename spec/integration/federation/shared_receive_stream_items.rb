# frozen_string_literal: true

# by "stream items" we mean everything that could appear in the stream - post, comment, like, poll, etc and therefore
# could be send either publicly or privately
shared_examples_for "messages which are indifferent about sharing fact" do
  let(:public) { recipient.nil? }

  it "treats status message receive correctly" do
    entity = Fabricate(:status_message_entity, author: sender_id, public: public)

    post_message(generate_payload(entity, sender, recipient), recipient)

    expect(StatusMessage.exists?(guid: entity.guid)).to be_truthy
  end

  it "doesn't accept status message with wrong signature" do
    allow(sender).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))
    entity = Fabricate(:status_message_entity, author: sender_id, public: public)

    post_message(generate_payload(entity, sender, recipient), recipient)

    expect(StatusMessage.exists?(guid: entity.guid)).to be_falsey
  end

  describe "with messages which require a status to operate on" do
    let(:local_parent) { FactoryGirl.create(:status_message, author: alice.person, public: public) }
    let(:remote_parent) { FactoryGirl.create(:status_message, author: remote_user_on_pod_b.person, public: public) }

    describe "notifications are sent where required" do
      it "for comment on local post" do
        entity = create_relayable_entity(:comment_entity, local_parent, remote_user_on_pod_b.diaspora_handle)
        post_message(generate_payload(entity, sender, recipient), recipient)

        expect(
          Notifications::CommentOnPost.exists?(
            recipient_id: alice.id,
            target_type:  "Post",
            target_id:    local_parent.id
          )
        ).to be_truthy
      end

      it "for like on local post" do
        entity = create_relayable_entity(:like_entity, local_parent, remote_user_on_pod_b.diaspora_handle)
        post_message(generate_payload(entity, sender, recipient), recipient)

        expect(
          Notifications::Liked.exists?(
            recipient_id: alice.id,
            target_type:  "Post",
            target_id:    local_parent.id
          )
        ).to be_truthy
      end
    end

    %w(comment like).each do |entity|
      context "with #{entity}" do
        let(:entity_name) { "#{entity}_entity".to_sym }
        let(:klass) { entity.camelize.constantize }

        it_behaves_like "it deals correctly with a relayable"
      end
    end

    context "with participations" do
      let(:entity) {
        Fabricate(
          :participation_entity,
          author:      sender_id,
          parent_guid: local_parent.guid,
          parent:      Diaspora::Federation::Entities.related_entity(local_parent)
        )
      }

      it "treats participation receive correctly" do
        expect(Workers::ReceiveLocal).to receive(:perform_async)
        post_message(generate_payload(entity, sender, recipient), recipient)

        received_entity = Participation.find_by(guid: entity.guid)
        expect(received_entity).not_to be_nil
        expect(received_entity.author.diaspora_handle).to eq(remote_user_on_pod_b.diaspora_handle)
      end

      it "rejects a participations for a remote parent" do
        expect(Workers::ReceiveLocal).not_to receive(:perform_async)
        entity = create_relayable_entity(:participation_entity, remote_parent, sender_id)

        post_message(generate_payload(entity, sender, recipient), recipient)

        expect(Participation.exists?(guid: entity.guid)).to be_falsey
      end
    end

    context "with poll_participation" do
      let(:local_parent) {
        FactoryGirl.create(
          :poll,
          status_message: FactoryGirl.create(:status_message, author: alice.person, public: public)
        )
      }
      let(:remote_parent) {
        FactoryGirl.create(
          :poll,
          status_message: FactoryGirl.create(:status_message, author: remote_user_on_pod_b.person, public: public)
        )
      }
      let(:entity_name) { :poll_participation_entity }
      let(:klass) { PollParticipation }

      it_behaves_like "it deals correctly with a relayable"
    end
  end
end

shared_examples_for "messages which can't be send without sharing" do
  # retractions shouldn't depend on sharing fact
  describe "retractions for non-relayable objects" do
    %w[status_message photo].each do |target|
      context "with #{target}" do
        let(:target_object) { FactoryGirl.create(target.to_sym, author: remote_user_on_pod_b.person) }

        it_behaves_like "it retracts non-relayable object"
      end
    end
  end

  describe "with messages which require a status to operate on" do
    let(:public) { recipient.nil? }
    let(:local_parent) { FactoryGirl.create(:status_message, author: alice.person, public: public) }
    let(:remote_parent) { FactoryGirl.create(:status_message, author: remote_user_on_pod_b.person, public: public) }

    # this one shouldn't depend on the sharing fact. this must be fixed
    describe "notifications are sent where required" do
      it "for comment on remote post where we participate" do
        alice.participate!(remote_parent)
        author_id = remote_user_on_pod_c.diaspora_handle
        entity = create_relayable_entity(:comment_entity, remote_parent, author_id)
        post_message(generate_payload(entity, sender, recipient), recipient)

        expect(
          Notifications::AlsoCommented.exists?(
            recipient_id: alice.id,
            target_type:  "Post",
            target_id:    remote_parent.id
          )
        ).to be_truthy
      end
    end

    describe "retractions for relayable objects" do
      before do
        allow(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key, alice.diaspora_handle
        ) { alice.encryption_key }
      end

      context "with comment" do
        it_behaves_like "it retracts relayable object" do
          # case for to-upstream federation
          let(:target_object) {
            FactoryGirl.create(:comment, author: remote_user_on_pod_b.person, post: local_parent)
          }
        end

        it_behaves_like "it retracts relayable object" do
          # case for to-downsteam federation
          let(:target_object) {
            FactoryGirl.create(:comment, author: remote_user_on_pod_c.person, post: remote_parent)
          }
        end
      end

      context "with like" do
        it_behaves_like "it retracts relayable object" do
          # case for to-upstream federation
          let(:target_object) {
            FactoryGirl.create(:like, author: remote_user_on_pod_b.person, target: local_parent)
          }
        end

        it_behaves_like "it retracts relayable object" do
          # case for to-downsteam federation
          let(:target_object) {
            FactoryGirl.create(:like, author: remote_user_on_pod_c.person, target: remote_parent)
          }
        end
      end
    end
  end
end
