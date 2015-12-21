# by "stream items" we mean everything that could appear in the stream - post, comment, like, poll, etc and therefore
# could be send either publicly or privately
def set_up_messages
  @local_target = FactoryGirl.create(:status_message, author: alice.person, public: @public)
  @remote_target = FactoryGirl.create(:status_message, author: remote_user_on_pod_b.person, public: @public)
end

shared_examples_for "messages which are indifferent about sharing fact" do
  it "treats status message receive correctly" do
    post_message(alice.guid, generate_status_message)

    expect(StatusMessage.exists?(guid: @entity.guid)).to be(true)
  end

  it "doesn't accept status message with wrong signature" do
    post_message(alice.guid, generate_forged_status_message)

    expect(StatusMessage.exists?(guid: @entity.guid)).to be(false)
  end

  describe "with messages which require a status to operate on" do
    before do
      set_up_messages
    end

    describe "notifications are sent where required" do
      it "for comment on local post" do
        post_message(alice.guid, generate_relayable_local_parent(:comment_entity))

        expect(
          Notifications::CommentOnPost.where(
            recipient_id: alice.id,
            target_type:  "Post",
            target_id:    @local_target.id
          ).first
        ).not_to be_nil
      end

      it "for like on local post" do
        post_message(alice.guid, generate_relayable_local_parent(:like_entity))

        expect(
          Notifications::Liked.where(
            recipient_id: alice.id,
            target_type:  "Post",
            target_id:    @local_target.id
          ).first
        ).not_to be_nil
      end
    end

    %w(comment like participation).each do |entity|
      context "with #{entity}" do
        it_behaves_like "it deals correctly with a relayable" do
          let(:entity_name) { "#{entity}_entity".to_sym }
          let(:klass) { entity.camelize.constantize }
        end
      end
    end

    context "with poll_participation" do
      before do
        @local_target = FactoryGirl.create(:poll, status_message: @local_target)
        @remote_target = FactoryGirl.create(:poll, status_message: @remote_target)
      end

      it_behaves_like "it deals correctly with a relayable" do
        let(:entity_name) { :poll_participation_entity }
        let(:klass) { PollParticipation }
      end
    end
  end
end

shared_examples_for "messages which can't be send without sharing" do
  # retractions shouldn't depend on sharing fact
  describe "retractions for non-relayable objects" do
    %w(
      retraction
      signed_retraction
    ).each do |retraction_entity_name|
      context "with #{retraction_entity_name}" do
        %w(status_message photo).each do |target|
          context "with #{target}" do
            it_behaves_like "it retracts non-relayable object" do
              let(:target_object) { FactoryGirl.create(target.to_sym, author: remote_user_on_pod_b.person) }
              let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }
            end
          end
        end
      end
    end
  end

  describe "with messages which require a status to operate on" do
    before do
      set_up_messages
    end

    # this one shouldn't depend on the sharing fact. this must be fixed
    describe "notifications are sent where required" do
      it "for comment on remote post where we participate" do
        alice.participate!(@remote_target)
        post_message(alice.guid, generate_relayable_remote_parent(:comment_entity))

        expect(
          Notifications::AlsoCommented.where(
            recipient_id: alice.id,
            target_type:  "Post",
            target_id:    @remote_target.id
          ).first
        ).not_to be_nil
      end
    end

    describe "retractions for relayable objects" do
      %w(
        retraction
        signed_retraction
        relayable_retraction
      ).each do |retraction_entity_name|
        context "with #{retraction_entity_name}" do
          context "with comment" do
            it_behaves_like "it retracts relayable object" do
              # case for to-upstream federation
              let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }
              let(:target_object) {
                FactoryGirl.create(:comment, author: remote_user_on_pod_b.person, post: @local_target)
              }
              let(:sender) { remote_user_on_pod_b }
            end

            it_behaves_like "it retracts relayable object" do
              # case for to-downsteam federation
              let(:target_object) {
                FactoryGirl.create(:comment, author: remote_user_on_pod_c.person, post: @remote_target)
              }
              let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }
              let(:sender) { remote_user_on_pod_b }
            end
          end

          context "with like" do
            it_behaves_like "it retracts relayable object" do
              # case for to-upstream federation
              let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }
              let(:target_object) {
                FactoryGirl.create(:like, author: remote_user_on_pod_b.person, target: @local_target)
              }
              let(:sender) { remote_user_on_pod_b }
            end

            it_behaves_like "it retracts relayable object" do
              # case for to-downsteam federation
              let(:target_object) {
                FactoryGirl.create(:like, author: remote_user_on_pod_c.person, target: @remote_target)
              }
              let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }
              let(:sender) { remote_user_on_pod_b }
            end
          end
        end
      end
    end
  end
end
