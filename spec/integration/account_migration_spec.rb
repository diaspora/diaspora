# frozen_string_literal: true

require "integration/federation/federation_helper"

def create_remote_contact(user, pod_host)
  FactoryGirl.create(
    :contact,
    user:   user,
    person: FactoryGirl.create(
      :person,
      pod:             Pod.find_or_create_by(url: "http://#{pod_host}"),
      diaspora_handle: "#{r_str}@#{pod_host}"
    )
  )
end

shared_examples_for "every migration scenario" do
  it "updates person references" do
    contact = FactoryGirl.create(:contact, person: old_person)
    post = FactoryGirl.create(:status_message, author: old_person)
    reshare = FactoryGirl.create(:reshare, author: old_person)
    photo = FactoryGirl.create(:photo, author: old_person)
    comment = FactoryGirl.create(:comment, author: old_person)
    like = FactoryGirl.create(:like, author: old_person)
    participation = FactoryGirl.create(:participation, author: old_person)
    poll_participation = FactoryGirl.create(:poll_participation, author: old_person)
    mention = FactoryGirl.create(:mention, person: old_person)
    message = FactoryGirl.create(:message, author: old_person)
    conversation = FactoryGirl.create(:conversation, author: old_person)
    block = FactoryGirl.create(:user).blocks.create(person: old_person)
    role = FactoryGirl.create(:role, person: old_person)

    # Create ConversationVisibility by creating a conversation with participants
    conversation2 = FactoryGirl.build(:conversation)
    FactoryGirl.create(:contact, user: old_user, person: conversation2.author) if old_person.local?
    conversation2.participants << old_person
    conversation2.save!
    visibility = ConversationVisibility.find_by(person_id: old_person.id)

    # In order to create a notification actor we need to create a notification first
    notification = FactoryGirl.build(:notification)
    notification.actors << old_person
    notification.save!
    actor = notification.notification_actors.find_by(person_id: old_person.id)

    run_migration

    expect(contact.reload.person).to eq(new_person)
    expect(post.reload.author).to eq(new_person)
    expect(reshare.reload.author).to eq(new_person)
    expect(photo.reload.author).to eq(new_person)
    expect(comment.reload.author).to eq(new_person)
    expect(like.reload.author).to eq(new_person)
    expect(participation.reload.author).to eq(new_person)
    expect(poll_participation.reload.author).to eq(new_person)
    expect(mention.reload.person).to eq(new_person)
    expect(message.reload.author).to eq(new_person)
    expect(conversation.reload.author).to eq(new_person)
    expect(block.reload.person).to eq(new_person)
    expect(role.reload.person).to eq(new_person)

    expect(visibility.reload.person).to eq(new_person)
    expect(actor.reload.person).to eq(new_person)
  end

  describe "old person account is closed and profile is cleared" do
    subject { old_person }

    before do
      run_migration
      subject.reload
    end

    include_examples "it makes account closed and clears profile"
  end

  describe "old person doesn't have any reference left" do
    let(:person) { old_person }

    before do
      DataGenerator.create(person, :generic_person_data)
    end

    def account_removal_method
      run_migration
      person.reload
    end

    include_examples "it removes the person associations"

    it "removes the person conversations" do
      expect {
        account_removal_method
      }.to change(nil, "conversations empty?") { Conversation.where(author: person).empty? }
        .to(be_truthy)
        .and(change(nil, "conversation visibilities of other participants empty?") {
          ConversationVisibility.where(conversation: Conversation.where(author: person)).empty?
        }.to(be_truthy))
    end
  end
end

shared_examples_for "migration scenarios with local old user" do
  it "locks the old user account" do
    run_migration
    expect(old_user.reload).to be_a_locked_account
  end
end

shared_examples_for "migration scenarios initiated remotely" do
  it "resends known contacts to the new user" do
    2.times do
      contact = FactoryGirl.create(:contact, person: old_user.person, sharing: true)
      expect(DiasporaFederation::Federation::Sender).to receive(:private)
        .with(
          contact.user_id,
          "Contact:#{contact.user.diaspora_handle}:#{new_user.diaspora_handle}",
          kind_of(Hash)
        ).and_return([])
    end

    inlined_jobs { run_migration }
  end
end

shared_examples_for "migration scenarios initiated locally" do
  it "dispatches account migration message to the federation" do
    expect(DiasporaFederation::Federation::Sender).to receive(:public) do |sender_id, obj_str, urls, xml|
      if old_user.person.remote?
        expect(sender_id).to eq(old_user.diaspora_handle)
      else
        expect(sender_id).to eq(old_user.id)
      end
      expect(obj_str).to eq("AccountMigration:#{old_user.diaspora_handle}:#{new_user.diaspora_handle}")
      subscribers = [remote_contact.person]
      subscribers.push(old_user) if old_user.person.remote?
      expect(urls).to match_array(subscribers.map(&:url).map {|url| "#{url}receive/public" })

      entity = nil
      expect {
        magic_env = Nokogiri::XML(xml).root
        entity = DiasporaFederation::Salmon::MagicEnvelope
                 .unenvelop(magic_env, old_user.diaspora_handle).payload
      }.not_to raise_error

      expect(entity).to be_a(DiasporaFederation::Entities::AccountMigration)
      expect(entity.author).to eq(old_user.diaspora_handle)
      expect(entity.profile.author).to eq(new_user.diaspora_handle)
      []
    end

    inlined_jobs do
      run_migration
    end
  end
end

shared_examples_for "migration scenarios with local user rename" do
  it "updates user references" do
    invited_user = FactoryGirl.create(:user, invited_by: old_user)
    aspect = FactoryGirl.create(:aspect, user: old_user, name: r_str)
    contact = FactoryGirl.create(:contact, user: old_user)
    service = FactoryGirl.create(:service, user: old_user)
    pref = UserPreference.create!(user: old_user, email_type: "also_commented")
    tag_following = FactoryGirl.create(:tag_following, user: old_user)
    block = FactoryGirl.create(:block, user: old_user)
    notification = FactoryGirl.create(:notification, recipient: old_user)
    report = FactoryGirl.create(:report, user: old_user)
    authorization = FactoryGirl.create(:auth_with_read_scopes, user: old_user)
    share_visibility = FactoryGirl.create(:share_visibility, user: old_user)

    run_migration

    expect(invited_user.reload.invited_by).to eq(new_user)
    expect(aspect.reload.user).to eq(new_user)
    expect(contact.reload.user).to eq(new_user)
    expect(service.reload.user).to eq(new_user)
    expect(pref.reload.user).to eq(new_user)
    expect(tag_following.reload.user).to eq(new_user)
    expect(block.reload.user).to eq(new_user)
    expect(notification.reload.recipient).to eq(new_user)
    expect(report.reload.user).to eq(new_user)
    expect(authorization.reload.user).to eq(new_user)
    expect(share_visibility.reload.user).to eq(new_user)
  end
end

describe "account migration" do
  # this is the case when we receive account migration message from the federation
  context "remotely initiated" do
    let(:entity) { create_account_migration_entity(old_user.diaspora_handle, new_user) }

    def run_migration
      allow_callbacks(%i[queue_public_receive fetch_public_key receive_entity])
      post_message(generate_payload(entity, old_user))
    end

    context "both new and old profiles are remote" do
      let(:old_user) { remote_user_on_pod_c }
      let(:old_person) { old_user.person }
      let(:new_user) { remote_user_on_pod_b }
      let(:new_person) { new_user.person }

      it "creates AccountMigration db object" do
        run_migration
        expect(AccountMigration.where(old_person: old_user.person, new_person: new_user.person)).to exist
      end

      include_examples "every migration scenario"

      include_examples "migration scenarios initiated remotely"

      context "when new person has been migrated before" do
        let(:intermidiate_person) { create_remote_user("remote-d.net").person }

        before do
          AccountMigration.create!(old_person: intermidiate_person, new_person: new_person).perform!
        end

        def run_migration
          AccountMigration.create!(old_person: old_person, new_person: intermidiate_person).perform!
        end

        include_examples "every migration scenario"

        include_examples "migration scenarios initiated remotely"
      end
    end

    # this is the case when we're a pod, which was left by a person in favor of remote one
    context "old user is local, new user is remote" do
      let(:old_user) { FactoryGirl.create(:user) }
      let(:old_person) { old_user.person }
      let(:new_user) { remote_user_on_pod_b }
      let(:new_person) { new_user.person }

      include_examples "every migration scenario"

      include_examples "migration scenarios initiated remotely"

      it_behaves_like "migration scenarios with local old user"

      it_behaves_like "deletes all of the user data" do
        let(:user) { old_user }

        before do
          DataGenerator.create(user, :generic_user_data)
        end

        def account_removal_method
          run_migration
          user.reload
        end
      end

      context "when new person has been migrated before" do
        let(:intermidiate_person) { create_remote_user("remote-d.net").person }

        before do
          AccountMigration.create!(old_person: intermidiate_person, new_person: new_person).perform!
        end

        def run_migration
          AccountMigration.create!(old_person: old_user.person, new_person: intermidiate_person).perform!
        end

        include_examples "every migration scenario"

        include_examples "migration scenarios initiated remotely"

        it_behaves_like "migration scenarios with local old user"
      end
    end
  end

  context "locally initiated" do
    before do
      allow(DiasporaFederation.callbacks).to receive(:trigger).and_call_original
    end

    # this is the case when user migrates to our pod from a remote one
    context "old user is remote and new user is local" do
      let(:old_user) { remote_user_on_pod_c }
      let(:old_person) { old_user.person }
      let(:new_user) { FactoryGirl.create(:user) }
      let(:new_person) { new_user.person }

      def run_migration
        AccountMigration.create!(
          old_person:      old_user.person,
          new_person:      new_user.person,
          old_private_key: old_user.serialized_private_key
        ).perform!
      end

      include_examples "every migration scenario"

      it_behaves_like "migration scenarios initiated locally" do
        let!(:remote_contact) { create_remote_contact(new_user, "remote-friend.org") }
      end

      context "when new person has been migrated before" do
        let(:intermidiate_person) { FactoryGirl.create(:user).person }

        before do
          AccountMigration.create!(old_person: intermidiate_person, new_person: new_person).perform!
        end

        def run_migration
          AccountMigration.create!(
            old_person:      old_person,
            new_person:      intermidiate_person,
            old_private_key: old_user.serialized_private_key
          ).perform!
        end

        include_examples "every migration scenario"
      end
    end

    # this is the case when a user changes diaspora id but stays on the same pod
    context "old user is local and new user is local" do
      let(:old_user) { FactoryGirl.create(:user) }
      let(:old_person) { old_user.person }
      let(:new_user) { FactoryGirl.create(:user) }
      let(:new_person) { new_user.person }

      def run_migration
        AccountMigration.create!(old_person: old_person, new_person: new_person).perform!
      end

      include_examples "every migration scenario"

      it_behaves_like "migration scenarios initiated locally" do
        let!(:remote_contact) { create_remote_contact(old_user, "remote-friend.org") }
      end

      it_behaves_like "migration scenarios with local old user"

      it "clears the old user account" do
        run_migration
        expect(old_user.reload).to be_a_clear_account
      end

      include_examples "migration scenarios with local user rename"

      context "when new user has been migrated before" do
        let(:intermidiate_person) { FactoryGirl.create(:user).person }

        before do
          AccountMigration.create!(old_person: intermidiate_person, new_person: new_person).perform!
        end

        def run_migration
          AccountMigration.create!(
            old_person: old_person,
            new_person: intermidiate_person
          ).perform!
        end

        include_examples "every migration scenario"

        it_behaves_like "migration scenarios with local old user"

        it "clears the old user account" do
          run_migration
          expect(old_user.reload).to be_a_clear_account
        end

        include_examples "migration scenarios with local user rename"
      end
    end
  end
end
