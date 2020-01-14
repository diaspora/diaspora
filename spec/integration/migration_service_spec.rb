# frozen_string_literal: true

require "integration/federation/federation_helper"
require "integration/archive_shared"

describe MigrationService do
  let(:old_pod_hostname) { "originalhomepod.tld" }
  let(:archive_author) { "previous_username@#{old_pod_hostname}" }
  let(:archive_private_key) { OpenSSL::PKey::RSA.generate(1024) }
  let(:contact1_diaspora_id) { known_contact_person.diaspora_handle }
  let(:contact2_diaspora_id) { Fabricate.sequence(:diaspora_id) }
  let(:unknown_subscription_guid) { UUID.generate(:compact) }
  let(:existing_subscription_guid) { UUID.generate(:compact) }
  let(:reshare_entity) { Fabricate(:reshare_entity, author: archive_author) }
  let(:reshare_entity_with_no_root) {
    Fabricate(:reshare_entity, author: archive_author, root_guid: nil, root_author: nil)
  }
  let(:unknown_status_message_entity) { Fabricate(:status_message_entity, author: archive_author, public: false) }
  let(:known_status_message_entity) { Fabricate(:status_message_entity, author: archive_author, public: false) }
  let(:colliding_status_message_entity) { Fabricate(:status_message_entity, author: archive_author) }
  let(:status_message_with_poll_entity) {
    Fabricate(:status_message_entity,
              author: archive_author,
              poll:   Fabricate(:poll_entity))
  }
  let(:status_message_with_location_entity) {
    Fabricate(:status_message_entity,
              author:   archive_author,
              location: Fabricate(:location_entity))
  }
  let(:status_message_with_photos_entity) {
    Fabricate(:status_message_entity,
              author: archive_author,
              photos: [
                Fabricate(:photo_entity, author: archive_author),
                Fabricate(:photo_entity, author: archive_author)
              ])
  }
  let(:comment_entity) {
    Fabricate(:comment_entity, author: archive_author, author_signature: "ignored XXXXXXXXXXXXXXXXXXXXXXXXXXX")
  }
  let(:like_entity) {
    Fabricate(:like_entity,
              author:           archive_author,
              author_signature: "ignored XXXXXXXXXXXXXXXXXXXXXXXXXXX",
              parent_guid:      FactoryGirl.create(:status_message).guid)
  }
  let(:poll_participation_entity) {
    poll = FactoryGirl.create(:status_message_with_poll).poll
    Fabricate(:poll_participation_entity,
              author:           archive_author,
              author_signature: "ignored XXXXXXXXXXXXXXXXXXXXXXXXXXX",
              poll_answer_guid: poll.poll_answers.first.guid,
              parent_guid:      poll.guid)
  }
  let(:unknown_poll_guid) { UUID.generate(:compact) }
  let(:unknown_poll_answer_guid) { UUID.generate(:compact) }
  let(:poll_participation_entity_unknown_root) {
    Fabricate(:poll_participation_entity,
              author:           archive_author,
              author_signature: "ignored XXXXXXXXXXXXXXXXXXXXXXXXXXX",
              poll_answer_guid: unknown_poll_answer_guid,
              parent_guid:      unknown_poll_guid)
  }
  let(:others_comment_entity) {
    data = Fabricate.attributes_for(:comment_entity,
                                    author:      remote_user_on_pod_b.diaspora_handle,
                                    parent_guid: unknown_status_message_entity.guid)
    data[:author_signature] = Fabricate(:comment_entity, data).sign_with_key(remote_user_on_pod_b.encryption_key)
    Fabricate(:comment_entity, data)
  }

  let(:post_subscriber) { FactoryGirl.create(:person) }
  let(:known_contact_person) { FactoryGirl.create(:person) }
  let!(:collided_status_message) { FactoryGirl.create(:status_message, guid: colliding_status_message_entity.guid) }
  let!(:collided_like) { FactoryGirl.create(:like, guid: like_entity.guid) }
  let!(:reshare_root_author) { FactoryGirl.create(:person, diaspora_handle: reshare_entity.root_author) }

  # This is for testing migrated contacts handling
  let(:account_migration) { FactoryGirl.create(:account_migration).tap(&:perform!) }
  let(:migrated_contact_diaspora_id) { account_migration.old_person.diaspora_handle }
  let(:migrated_contact_new_diaspora_id) { account_migration.new_person.diaspora_handle }

  let(:posts_in_archive) {
    [
      reshare_entity,
      unknown_status_message_entity,
      known_status_message_entity,
      reshare_entity_with_no_root,
      colliding_status_message_entity,
      status_message_with_poll_entity,
      status_message_with_location_entity,
      status_message_with_photos_entity
    ]
  }

  let(:posts_in_archive_json) {
    posts = posts_in_archive.map {|post|
      post.to_json.as_json
    }
    posts[0]["subscribed_pods_uris"] = []
    posts[1]["subscribed_users_ids"] = [post_subscriber.diaspora_handle]
    posts[2]["subscribed_users_ids"] = [post_subscriber.diaspora_handle]
    posts[3]["subscribed_pods_uris"] = []
    posts[4]["subscribed_pods_uris"] = []
    posts[5]["subscribed_pods_uris"] = []
    posts[6]["subscribed_pods_uris"] = []
    posts[7]["subscribed_pods_uris"] = []
    posts.to_json
  }

  let(:archive_json) { <<~JSON }
    {
      "user": {
        "username": "previous_username",
        "email": "mail@example.com",
        "private_key": #{archive_private_key.export.dump},
        "profile": {
          "entity_type": "profile",
          "entity_data": {
            "author": "#{archive_author}"
          }
        },
        "contacts": [
          {
            "sharing": true,
            "receiving": false,
            "following": true,
            "followed": false,
            "account_id": "#{contact1_diaspora_id}",
            "contact_groups_membership": ["Family"]
          },
          {
            "sharing": true,
            "receiving": true,
            "following": true,
            "followed": true,
            "account_id": "#{migrated_contact_diaspora_id}",
            "contact_groups_membership": ["Family"]
          },
          {
            "sharing": true,
            "receiving": true,
            "following": true,
            "followed": true,
            "account_id": "#{contact2_diaspora_id}",
            "contact_groups_membership": ["Family"]
          }
        ],
        "contact_groups": [
          {"name":"Friends"}
        ],
        "post_subscriptions": [
          "#{unknown_subscription_guid}",
          "#{existing_subscription_guid}"
        ],
        "posts": #{posts_in_archive_json},
        "relayables": [
              #{comment_entity.to_json.as_json.to_json},
              #{like_entity.to_json.as_json.to_json},
              #{poll_participation_entity.to_json.as_json.to_json},
              #{poll_participation_entity_unknown_root.to_json.as_json.to_json}
        ]
      },
      "others_data": {
        "relayables": [
           #{others_comment_entity.to_json.as_json.to_json}
        ]
      },
      "version": "2.0"
    }
  JSON

  def expect_reshare_root_fetch(root_author, root_guid)
    expect(DiasporaFederation::Federation::Fetcher)
      .to receive(:fetch_public)
        .with(root_author.diaspora_handle, "Post", root_guid) {
          FactoryGirl.create(:status_message, guid: root_guid, author: root_author, public: true)
        }
  end

  def expect_relayable_parent_fetch(relayable_author, parent_guid, parent_type="Post", &block)
    expect(DiasporaFederation::Federation::Fetcher)
      .to receive(:fetch_public)
      .with(relayable_author, parent_type, parent_guid, &block)
  end

  let(:new_username) { "newuser" }
  let(:new_user_handle) { "#{new_username}@#{AppConfig.bare_pod_uri}" }

  let(:archive_file) { Tempfile.new("archive") }

  def setup_validation_time_expectations
    expect_person_fetch(contact2_diaspora_id, nil)

    # This is expected to be called during relayable validation
    expect_relayable_parent_fetch(archive_author, comment_entity.parent_guid) {
      FactoryGirl.create(:status_message, guid: comment_entity.parent_guid)
    }

    expect_relayable_parent_fetch(archive_author, unknown_poll_guid, "Poll") {
      FactoryGirl.create(
        :poll_answer,
        poll: FactoryGirl.create(:poll, guid: unknown_poll_guid),
        guid: unknown_poll_answer_guid
      )
    }
  end

  before do
    archive_file.write(archive_json)
    archive_file.close
    allow_callbacks(
      %i[queue_public_receive fetch_related_entity fetch_person_url_to fetch_public_key receive_entity
         fetch_private_key]
    )
  end

  shared_examples "imports archive" do
    it "imports archive" do
      expect_relayable_parent_fetch(archive_author, unknown_subscription_guid) {
        FactoryGirl.create(:status_message, guid: unknown_subscription_guid)
      }

      expect_reshare_root_fetch(reshare_root_author, reshare_entity.root_guid)

      service = MigrationService.new(archive_file.path, new_username)
      service.validate
      expect(service.warnings).to eq(
        ["reshare Reshare:#{reshare_entity_with_no_root.guid} doesn't have a root, ignored"]
      )
      service.perform!
      user = User.find_by(username: new_username)
      expect(user).not_to be_nil

      unless Person.by_account_identifier(archive_author).nil?
        expect(AccountMigration.where(new_person: user.person).any?).to be_truthy

        existing_contact.reload
        expect(existing_contact.person).to eq(user.person)
        expect(existing_contact.sharing).to be_truthy
        expect(existing_contact.receiving).to be_truthy
      end

      status_message = StatusMessage.find_by(guid: unknown_status_message_entity.guid)
      expect(status_message.author).to eq(user.person)
      # TODO: rewrite this expectation when new subscription implementation is there
      # expect(status_message.participants).to include(post_subscriber)

      status_message = StatusMessage.find_by(guid: known_status_message_entity.guid)
      expect(status_message.author).to eq(user.person)
      # TODO: rewrite this expectation when new subscription implementation is there
      # expect(status_message.participants).to include(post_subscriber)

      status_message = StatusMessage.find_by(guid: status_message_with_poll_entity.guid)
      expect(status_message.author).to eq(user.person)
      poll = status_message.poll
      expect(poll).not_to be_nil
      expect(poll.guid).to eq(status_message_with_poll_entity.poll.guid)
      expect(poll.question).to eq(status_message_with_poll_entity.poll.question)
      expect(poll.poll_answers.pluck(:answer, :guid)).to eq(
        status_message_with_poll_entity.poll.poll_answers.map {|answer| [answer.answer, answer.guid] }
      )

      status_message = StatusMessage.find_by(guid: status_message_with_location_entity.guid)
      expect(status_message.author).to eq(user.person)
      expect(status_message.location.address).to eq(status_message_with_location_entity.location.address)
      expect(status_message.location.lat).to eq(status_message_with_location_entity.location.lat)
      expect(status_message.location.lng).to eq(status_message_with_location_entity.location.lng)

      status_message = StatusMessage.find_by(guid: status_message_with_photos_entity.guid)
      expect(status_message.author).to eq(user.person)
      expect(
        status_message.photos.pluck(:guid, :text, :remote_photo_path, :remote_photo_name, :width, :height)
      ).to match_array(
        status_message_with_photos_entity.photos.map {|photo|
          [photo.guid, photo.text, photo.remote_photo_path, photo.remote_photo_name, photo.width, photo.height]
        }
      )

      comment = Comment.find_by(guid: comment_entity.guid)
      expect(comment.author).to eq(user.person)

      # Here we're testing the case when the like in the archive has the guid colliding with another known like
      like = Like.find_by(guid: like_entity.guid)
      expect(like.author).not_to eq(user.person)

      contact = user.contacts.find_by(person: Person.by_account_identifier(contact1_diaspora_id))
      expect(contact).not_to be_nil
      expect(contact.sharing).to be_falsey
      expect(contact.receiving).to be_falsey

      contact = user.contacts.find_by(person: Person.by_account_identifier(contact2_diaspora_id))
      expect(contact).not_to be_nil
      expect(contact.sharing).to be_falsey
      expect(contact.receiving).to be_truthy

      contact = user.contacts.find_by(person: Person.by_account_identifier(migrated_contact_new_diaspora_id))
      expect(contact).not_to be_nil
      expect(contact.sharing).to be_falsey
      expect(contact.receiving).to be_truthy

      aspect = user.aspects.find_by(name: "Friends")
      expect(aspect).not_to be_nil

      poll_participation = PollParticipation.find_by(author: user.person, guid: poll_participation_entity.guid)
      expect(poll_participation).not_to be_nil
      expect(poll_participation.parent.guid).to eq(poll_participation_entity.parent_guid)
      expect(poll_participation.poll_answer.guid).to eq(poll_participation_entity.poll_answer_guid)

      comment = Comment.find_by(guid: others_comment_entity.guid)
      expect(comment.author.diaspora_handle).to eq(others_comment_entity.author)
      expect(comment.parent.author.diaspora_handle).to eq(user.diaspora_handle)
    end
  end

  context "old user is a known remote user" do
    let(:old_person) {
      FactoryGirl.create(:person,
                         profile:               FactoryGirl.build(:profile),
                         serialized_public_key: archive_private_key.public_key.export,
                         diaspora_handle:       archive_author)
    }

    # Some existing data for old_person to test data merge/migration
    let!(:existing_contact) { FactoryGirl.create(:contact, person: old_person, sharing: true, receiving: true) }

    let!(:existing_subscription) {
      FactoryGirl.create(:participation,
                         author: old_person,
                         target: FactoryGirl.create(:status_message, guid: existing_subscription_guid))
    }
    let!(:existing_status_message) {
      FactoryGirl.create(:status_message,
                         author: old_person,
                         guid:   known_status_message_entity.guid).tap {|status_message|
        status_message.participants << post_subscriber
      }
    }

    it_behaves_like "imports archive" do
      before do
        setup_validation_time_expectations
      end
    end

    context "when account migration already exists" do
      before do
        setup_validation_time_expectations
        FactoryGirl.create(:account_migration, old_person: old_person)
      end

      it "raises exception" do
        expect {
          MigrationService.new(archive_file.path, new_username).validate
        }.to raise_error(MigrationService::MigrationAlreadyExists)
      end
    end

    describe "#only_import?" do
      it "returns false" do
        service = MigrationService.new(archive_file.path, new_username)
        expect(service.only_import?).to be_falsey
      end
    end
  end

  context "old user is unknown" do
    context "and non-fetchable" do
      before do
        expect(DiasporaFederation::Discovery::Discovery).to receive(:new).with(archive_author).and_call_original
        stub_request(:get, "https://#{old_pod_hostname}/.well-known/webfinger?resource=acct:#{archive_author}")
          .to_return(status: 404)
        stub_request(:get, %r{https*://#{old_pod_hostname}/\.well-known/host-meta})
          .to_return(status: 404)

        expect_relayable_parent_fetch(archive_author, existing_subscription_guid)
          .and_raise(DiasporaFederation::Federation::Fetcher::NotFetchable)

        setup_validation_time_expectations
      end

      include_examples "imports archive"
    end

    describe "#only_import?" do
      it "returns true" do
        service = MigrationService.new(archive_file.path, new_username)
        expect(service.only_import?).to be_truthy
      end
    end
  end
end
