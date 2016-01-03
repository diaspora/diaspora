# by "stream items" we mean everything that could appear in the stream - post, comment, like, poll, etc and therefore
# could be send either publicly or privately
shared_examples_for "messages which are indifferent about sharing fact" do
  let(:public) { recipient.nil? }

  it "treats status message receive correctly" do
    entity = FactoryGirl.build(:status_message_entity, diaspora_id: sender_id, public: public)

    post_message(generate_xml(entity, sender, recipient), recipient)

    expect(StatusMessage.exists?(guid: entity.guid)).to be_truthy
  end

  it "doesn't accept status message with wrong signature" do
    allow(sender).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))
    entity = FactoryGirl.build(:status_message_entity, diaspora_id: sender_id, public: public)

    post_message(generate_xml(entity, sender, recipient), recipient)

    expect(StatusMessage.exists?(guid: entity.guid)).to be_falsey
  end

  describe "with messages which require a status to operate on" do
    let(:local_target) { FactoryGirl.create(:status_message, author: alice.person, public: public) }
    let(:remote_target) { FactoryGirl.create(:status_message, author: remote_user_on_pod_b.person, public: public) }

    describe "notifications are sent where required" do
      it "for comment on local post" do
        entity = create_relayable_entity(:comment_entity, local_target, remote_user_on_pod_b.diaspora_handle, nil)
        post_message(generate_xml(entity, sender, recipient), recipient)

        expect(
          Notifications::CommentOnPost.exists?(
            recipient_id: alice.id,
            target_type:  "Post",
            target_id:    local_target.id
          )
        ).to be_truthy
      end

      it "for like on local post" do
        entity = create_relayable_entity(:like_entity, local_target, remote_user_on_pod_b.diaspora_handle, nil)
        post_message(generate_xml(entity, sender, recipient), recipient)

        expect(
          Notifications::Liked.exists?(
            recipient_id: alice.id,
            target_type:  "Post",
            target_id:    local_target.id
          )
        ).to be_truthy
      end
    end

    %w(comment like participation).each do |entity|
      context "with #{entity}" do
        let(:entity_name) { "#{entity}_entity".to_sym }
        let(:klass) { entity.camelize.constantize }

        it_behaves_like "it deals correctly with a relayable"
      end
    end

    context "with poll_participation" do
      let(:local_target) {
        FactoryGirl.create(
          :poll,
          status_message: FactoryGirl.create(:status_message, author: alice.person, public: public)
        )
      }
      let(:remote_target) {
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
    %w(retraction signed_retraction).each do |retraction_entity_name|
      context "with #{retraction_entity_name}" do
        let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }

        %w(status_message photo).each do |target|
          context "with #{target}" do
            let(:target_object) { FactoryGirl.create(target.to_sym, author: remote_user_on_pod_b.person) }

            it_behaves_like "it retracts non-relayable object"
          end
        end
      end
    end
  end

  describe "with messages which require a status to operate on" do
    let(:public) { recipient.nil? }
    let(:local_target) { FactoryGirl.create(:status_message, author: alice.person, public: public) }
    let(:remote_target) { FactoryGirl.create(:status_message, author: remote_user_on_pod_b.person, public: public) }

    # this one shouldn't depend on the sharing fact. this must be fixed
    describe "notifications are sent where required" do
      it "for comment on remote post where we participate" do
        alice.participate!(remote_target)
        author_id = remote_user_on_pod_c.diaspora_handle
        entity = create_relayable_entity(:comment_entity, remote_target, author_id, sender.encryption_key)
        post_message(generate_xml(entity, sender, recipient), recipient)

        expect(
          Notifications::AlsoCommented.exists?(
            recipient_id: alice.id,
            target_type:  "Post",
            target_id:    remote_target.id
          )
        ).to be_truthy
      end
    end

    describe "retractions for relayable objects" do
      %w(retraction signed_retraction relayable_retraction).each do |retraction_entity_name|
        context "with #{retraction_entity_name}" do
          let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }

          context "with comment" do
            it_behaves_like "it retracts relayable object" do
              # case for to-upstream federation
              let(:target_object) {
                FactoryGirl.create(:comment, author: remote_user_on_pod_b.person, post: local_target)
              }
            end

            it_behaves_like "it retracts relayable object" do
              # case for to-downsteam federation
              let(:target_object) {
                FactoryGirl.create(:comment, author: remote_user_on_pod_c.person, post: remote_target)
              }
            end
          end

          context "with like" do
            it_behaves_like "it retracts relayable object" do
              # case for to-upstream federation
              let(:target_object) {
                FactoryGirl.create(:like, author: remote_user_on_pod_b.person, target: local_target)
              }
            end

            it_behaves_like "it retracts relayable object" do
              # case for to-downsteam federation
              let(:target_object) {
                FactoryGirl.create(:like, author: remote_user_on_pod_c.person, target: remote_target)
              }
            end
          end
        end
      end
    end
  end
end
